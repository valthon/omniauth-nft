# OmniAuth::Nft

OmniAuth strategy for authenticating via NFT ownership

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-nft'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install omniauth-nft

## Usage

Add as a strategy to your omniauth config.  Eg:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :nft,
           checker_type: :opensea,
           checker_options: { testnet: true },
           nft_collection: { slug: 'untitled-collection-4919696' }
  provider :developer unless Rails.env.production?
end
```
This configuration will run against OpenSea testnet and allow login for anyone that owns an NFT in the
[Test Prota Collection](https://testnets.opensea.io/collection/untitled-collection-4919696)

UID is set to a combination of nft_collection slug and the nft token_id.
Authenticated users will have an auth.info hash with the name and image url of the NFT.
`auth.extra` contains a `wallet` key (the authenticated wallet address) and a `raw_info`
hash which contains all NFT metadata retrieved by `NftChecker`.

You can implement `User#find_or_create_from_auth_hash` like this:
```ruby
def User.find_or_create_from_auth_hash(auth)
  identity = { provider: auth['provider'], uid: auth['uid'] }
  User.find_or_create_by!(identity) do |record|
    case auth[:provider]
    when 'nft'
      record.name = auth.info['name']
      record.profile_url = auth.info['image']
    else
      raise 'Unexpected provider!'
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/valthon/omniauth-nft.
