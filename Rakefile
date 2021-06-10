# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

csv_create_tasks = [:customers, :merchants, :invoices, :items, :invoice_items, :transactions]
csv_clear_tasks = [:transactions, :invoice_items, :items, :invoices, :customers, :merchants]

namespace :clear_db do
  task :customers => :environment do
    start = Time.now
    puts '-- clearing old data on customers'
    Customer.destroy_all
    finish = Time.now
    puts "-- Done in %0.1f seconds" % [finish - start]
  end

  task :invoice_items => :environment do
    start = Time.now
    puts '-- clearing old data on invoice_items'
    InvoiceItem.destroy_all
    finish = Time.now
    puts "-- Done in %0.1f seconds" % [finish - start]
  end

  task :invoices => :environment do
    start = Time.now
    puts '-- clearing old data on invoices'
    Invoice.destroy_all
    finish = Time.now
    puts "-- Done in %0.1f seconds" % [finish - start]
  end

  task :items => :environment do
    start = Time.now
    puts '-- clearing old data on items'
    Item.destroy_all
    finish = Time.now
    puts "-- Done in %0.1f seconds" % [finish - start]
  end

  task :merchants => :environment do
    start = Time.now
    puts '-- clearing old data on merchants'
    Merchant.destroy_all
    finish = Time.now
    puts "-- Done in %0.1f seconds" % [finish - start]
  end

  task :transactions => :environment do
    start = Time.now
    puts '-- clearing old data on transactions'
    Transaction.destroy_all
    finish = Time.now
    puts "-- Done in %0.1f seconds" % [finish - start]
  end

  task :customers => :environment do
    start = Time.now
    puts '-- clearing old data on customers'
    Customer.destroy_all
    finish = Time.now
    puts "-- Done in %0.1f seconds" % [finish - start]
  end

  task :all => :environment do
    csv_clear_tasks.each do |task|
      Rake::Task["clear_db:#{task.to_s}"].reenable
      Rake::Task["clear_db:#{task.to_s}"].invoke
    end
  end
end

namespace :load_csv do
  task :customers => :environment do
    start = Time.now
    puts '-- Loading Customers ... '

    CSV.foreach('./db/data/customers.csv', headers: true) do |row|
      Customer.create!(row.to_hash)
    end

    ActiveRecord::Base.connection.reset_pk_sequence!(:customers)
    finish = Time.now
    puts "-- Done in %0.1f seconds" % [finish - start]
  end

  task :invoice_items => :environment do
    start = Time.now
    puts '-- Loading Invoice Items ... '

    CSV.foreach('./db/data/invoice_items.csv', headers: true) do |row|

      hash = row.to_hash
      hash['status'] = hash['status'].parameterize.underscore.to_sym

      InvoiceItem.create!(hash)
    end

    ActiveRecord::Base.connection.reset_pk_sequence!(:invoice_items)
    finish = Time.now
    puts "-- Done in %0.1f seconds" % [finish - start]
  end

  task :invoices => :environment do
    start = Time.now
    puts '-- Loading Invoices ... '

    CSV.foreach('./db/data/invoices.csv', headers: true) do |row|

      hash = row.to_hash
      hash['status'] = hash['status'].parameterize.underscore.to_sym

      Invoice.create!(hash)
    end

    ActiveRecord::Base.connection.reset_pk_sequence!(:invoices)
    finish = Time.now
    puts "-- Done in %0.1f seconds" % [finish - start]
  end

  task :items => :environment do
    start = Time.now
    puts '-- Loading Items ... '

    CSV.foreach('./db/data/items.csv', headers: true) do |row|
      Item.create!(row.to_hash)
    end

    ActiveRecord::Base.connection.reset_pk_sequence!(:items)
    finish = Time.now
    puts "-- Done in %0.1f seconds" % [finish - start]
  end

  task :merchants => :environment do
    start = Time.now
    puts '-- Loading Merchants ... '

    CSV.foreach('./db/data/merchants.csv', headers: true) do |row|
      Merchant.create!(row.to_hash)
    end

    ActiveRecord::Base.connection.reset_pk_sequence!(:merchants)
    finish = Time.now
    puts "-- Done in %0.1f seconds" % [finish - start]
  end

  task :transactions => :environment do
    start = Time.now
    puts '-- Loading Transactions ... '

    CSV.foreach('./db/data/transactions.csv', headers: true) do |row|

      hash = row.to_hash
      hash['result'] = hash['result'].parameterize.underscore.to_sym

      Transaction.create!(hash)
      ActiveRecord::Base.connection.reset_pk_sequence!(:transactions)
    end

    finish = Time.now
    puts "-- Done in %0.1f seconds" % [finish - start]
  end

  task :all => :environment do
    csv_create_tasks.each do |task|
      Rake::Task["load_csv:#{task.to_s}"].reenable
      Rake::Task["load_csv:#{task.to_s}"].invoke
    end
  end
end