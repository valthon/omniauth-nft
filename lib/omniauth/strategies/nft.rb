# frozen_string_literal: true

require "omniauth"
require "nft_checker"
require "eth"

module OmniAuth
  module Strategies
    # An OmniAuth strategy for authenticating via NFT ownership
    class Nft
      include OmniAuth::Strategy

      option :checker_type, :opensea
      option :checker_options, {}
      option :nft_collection, {}
      # option :form, OmniAuth::Nft::NftController.action(:request_phase)
      # option :form, true

      def request_phase
        OmniAuth::Nft::NftController.action(:request_phase).call(env)
      end
      # def request_phase
      #   checker = NftChecker.init(options.checker_type, options.checker_options)
      #   # checker.list_nfts({slug: 'untitled-collection-4919696'}, '0x051c6B791044102Ae773e27FEA21480ed6D653F4'
      #   raise 'party 2!'
      #
      # end

      attr_reader :nft, :address

      uid do
        "#{nft["asset_contract"]["address"]}::#{nft["token_id"]}"
      end

      info do
        {
          "name" => nft["name"],
          "image" => nft["image_url"]
        }
      end

      extra do
        {
          "wallet" => address,
          "raw_info" => nft
        }
      end

      def callback_phase # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        nft_params = ActionController::Parameters.new(request.params).permit(:address, :nft_id, :nft_contract, :sig)
        return fail!(:no_wallet_address) if nft_params[:address].blank?
        return fail!(:no_nft) if nft_params[:nft_id].blank? || nft_params[:nft_contract].blank?

        nft_metadata = { contract_address: nft_params[:nft_contract], token_id: nft_params[:nft_id] }
        nft = checker.fetch_nft_for_owner(nft_params[:address], nft_metadata)
        return fail!(:invalid_nft) if nft.blank?

        # At this point, we know the users owns the NFT, but not if it's part of our collection
        return fail!(:not_in_collection) unless verify_collection(nft["collection"])

        # Now we have verified the address owns the NFT and that the NFT is in our collection
        return fail!(:invalid_signature) unless verify_signature(nft_params[:address], session["nft__sig_message"],
                                                                 nft_params[:sig])

        # And, completing the validation, we know the current user session owns the owning wallet
        @address = nft_params[:address]
        @nft = nft
        super
      end

      private

      def checker
        @checker = NftChecker.init(options.checker_type, options.checker_options)
      end

      def verify_signature(address, message, signature)
        recovered_public_key = Eth::Key.personal_recover(message, signature)
        recovered_address = Eth::Utils.public_key_to_address(recovered_public_key)
        recovered_address.casecmp(address).zero?
      end

      def verify_collection(nft_collection)
        return false if nft_collection.blank?

        options.nft_collection.each_key do |key|
          return false unless nft_collection[key.to_s].casecmp(options.nft_collection[key]).zero?
        end
        true
      end
    end
  end
end
