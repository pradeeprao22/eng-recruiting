require 'sinatra'
require 'sinatra/reloader'
require 'open-uri'

set :protection, :except => :frame_options
set :bind, '0.0.0.0'
set :port, 8080

get '/' do
  # Your implementation goes here
  # Make a GET request to the API
  uri = URI('https://quietstreamfinancial.github.io/eng-recruiting/transactions.json')
  response = URI.open(uri)

  # Parse the JSON response
  transactions = JSON.parse(response.read)

  # Initialize a hash to store customer data
  customer_summary = {}

  # Process the data and calculate balances
  transactions.each do |transaction|
    customer_id = transaction['customer_id']
    account_type = transaction['account_type']
    transaction_amount = transaction['transaction_amount'].gsub('$', '').to_f

    # Initialize the customer's summary if it doesn't exist
    customer_summary[customer_id] ||= {
      'name' => transaction['customer_name'],
      'checking_balance' => 0.0,
      'savings_balance' => 0.0,
      'total_balance' => 0.0
    }

    # Update balances based on account type
    case account_type
    when 'checking'
      customer_summary[customer_id]['checking_balance'] += transaction_amount
    when 'savings'
      customer_summary[customer_id]['savings_balance'] += transaction_amount
    end

    # Update the total balance
    customer_summary[customer_id]['total_balance'] += transaction_amount
  end

  erb :table, locals: { customer_summary: customer_summary, title: 'Summary Page' }
end