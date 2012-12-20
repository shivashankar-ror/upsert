require 'spec_helper'
describe Upsert do
  describe 'hstore on pg' do
    it "just works" do
      require 'pg_hstore'
      Pet.connection.execute 'CREATE EXTENSION HSTORE'
      Pet.connection.execute "ALTER TABLE pets ADD COLUMN crazy HSTORE"
      upsert = Upsert.new $conn, :pets

      upsert.row({name: 'Bill'}, crazy: nil)
      row = Pet.connection.select_one(%{SELECT crazy FROM pets WHERE name = 'Bill'})
      row['crazy'].should == nil

      upsert.row({name: 'Bill'}, crazy: {a: 1})
      row = Pet.connection.select_one(%{SELECT crazy FROM pets WHERE name = 'Bill'})
      crazy = PgHstore.parse row['crazy']
      crazy.should == { a: '1' }

      upsert.row({name: 'Bill'}, crazy: nil)
      row = Pet.connection.select_one(%{SELECT crazy FROM pets WHERE name = 'Bill'})
      row['crazy'].should == nil

      upsert.row({name: 'Bill'}, crazy: {a: 1})
      row = Pet.connection.select_one(%{SELECT crazy FROM pets WHERE name = 'Bill'})
      crazy = PgHstore.parse row['crazy']
      crazy.should == { a: '1' }

      upsert.row({name: 'Bill'}, crazy: {whatdat: 'whodat'})
      row = Pet.connection.select_one(%{SELECT crazy FROM pets WHERE name = 'Bill'})
      crazy = PgHstore.parse row['crazy']
      crazy.should == { a: '1', whatdat: 'whodat' }

      upsert.row({name: 'Bill'}, crazy: {whatdat: "D'ONOFRIO"})
      row = Pet.connection.select_one(%{SELECT crazy FROM pets WHERE name = 'Bill'})
      crazy = PgHstore.parse row['crazy']
      crazy.should == { a: '1', whatdat: "D'ONOFRIO" }

      upsert.row({name: 'Bill'}, crazy: {a: 2})
      row = Pet.connection.select_one(%{SELECT crazy FROM pets WHERE name = 'Bill'})
      crazy = PgHstore.parse row['crazy']
      crazy.should == { a: '2', whatdat: "D'ONOFRIO" }
    end
  end
end if ENV['DB'] == 'postgresql'
