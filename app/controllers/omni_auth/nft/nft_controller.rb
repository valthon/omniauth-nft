# frozen_string_literal: true

require "eth"
module OmniAuth
  module Nft
    # Controller for OmniAuth::Strategies::Nft request phase.
    class NftController < ActionController::Base
      WALLET_SIG_SESSION_KEY = "nft__wallet_sig"
      SIG_MESSAGE_SESSION_KEY = "nft__sig_message"

      def request_phase
        return unless address.present?

        @address = address
        return unless address_signed?

        @sig = sig
        checker = NftChecker.init(:opensea, testnet: true)
        @list = checker.list_nfts({ slug: "untitled-collection-4919696" }, address)
      end

      private

      def address
        @address ||= begin
          address = params.permit(:address)[:address].to_s
          address if address =~ /\A0x[A-Za-z0-9]+\z/
        end
      end

      def sig
        @sig ||= begin
          sig = params.permit(:sig)[:sig]
          session[WALLET_SIG_SESSION_KEY] = sig if sig.present?
          session[WALLET_SIG_SESSION_KEY]
        end
      end

      def session_secret_message
        session[SIG_MESSAGE_SESSION_KEY] ||= <<~SECRET
          This is to verify you own the wallet with ID #{address}

          | #{SecureRandom.uuid} |
        SECRET
      end

      def address_signed?
        @msg = session_secret_message
        recovered_public_key = Eth::Key.personal_recover(@msg, sig)
        recovered_address = Eth::Utils.public_key_to_address(recovered_public_key)
        @sig_valid = recovered_address.casecmp(address).zero?
      rescue StandardError
        @sig_valid = false
      end
    end
  end
end
