# -*- coding: utf-8 -*-
require 'spec_helper'

describe Mongoid::Slug do

  context "when the object uses a single field as slug" do

    before :all do
      class Book
        include Mongoid::Document
        include Mongoid::Slug
        field :title
        slug :title, :index => true
      end
    end

    let(:book) { Book.create(:title => "A thousand plateaus") }
    subject    { book }

    # it { should have_index_for(slug: 1) }

    it "generates a slug" do
      expect(book.slug).to eq("a-thousand-plateaus")
    end

    it "updates the slug" do
      book.title = "Anti Ödipus"
      book.save
      expect(book.slug).to eq("anti-oedipus")
    end

    it "generates a unique slug by appending a counter to duplicate text" do
      15.times { |x|
        dup = Book.create(:title => book.title)
        expect(dup.slug).to eql "a-thousand-plateaus-#{x+1}"
      }
    end

    it "does not update slug if slugged fields have not changed" do
      book.save
      expect(book.slug).to eq("a-thousand-plateaus")
    end

    it "does not change slug if slugged fields have changed but generated slug is identical" do
      book.title = "a thousand plateaus"
      book.save
      expect(book.slug).to eq("a-thousand-plateaus")
    end

    it "finds by slug" do
      expect(Book.find_by_slug(book.slug)).to eq(book)
    end

  end

  # --------------------------------------------------------

  context "when the slug is composed of multiple fields" do

    before :all do
      class Author
        include Mongoid::Document
        include Mongoid::Slug
        field :first_name
        field :last_name
        slug :first_name, :last_name
      end
    end

    let(:author) do
      Author.create :first_name => "Gilles", :last_name => "Deleuze"
    end

    it "generates a slug" do
      expect(author.slug).to eq("gilles-deleuze")
    end

    it "updates the slug" do
      author.first_name = "Félix"
      author.last_name = "Guattari"
      author.save
      expect(author.slug).to eq("felix-guattari")
    end

    it "generates a unique slug by appending a counter to duplicate text" do
      dup = Author.create(
        :first_name => author.first_name,
        :last_name => author.last_name)
      expect(dup.slug).to eq('gilles-deleuze-1')

      dup2 = Author.create(
        :first_name => author.first_name,
        :last_name => author.last_name)

      dup.save
      expect(dup2.slug).to eq('gilles-deleuze-2')
    end

    it "does not update slug if slugged fields have changed but generated slug is identical" do
      author.last_name = "DELEUZE"
      author.save
      expect(author.slug).to eq('gilles-deleuze')
    end

    it "finds by slug" do
      author
      expect(Author.find_by_slug("gilles-deleuze")).to eq(author)
    end

  end

  context "when :as is passed as an argument" do

    before :all do
      class Person
        include Mongoid::Document
        include Mongoid::Slug

        field :name
        slug :name, :as => :permalink
      end
    end

    let(:person) do
      Person.create(:name => "John Doe")
    end

    it "sets an alternative slug field name" do
      expect(person).to respond_to(:permalink)
      expect(person.permalink).to eql "john-doe"
    end

    it "finds by slug" do
      person
      expect(Person.find_by_permalink("john-doe")).to eq(person)
    end

  end

  context "when :permanent is passed as an argument" do

    before :all do
      class FakeCity
        include Mongoid::Document
        include Mongoid::Slug

        field :name
        slug :name, :permanent => true
      end
    end

    let(:city) do
      FakeCity.create(:name => "Leipzig")
    end

    it "does not update the slug when the slugged fields change" do
      city.name = "Berlin"
      city.save
      expect(city.slug).to eq("leipzig")
    end
  end

  context "when :slug is given a block" do

    before :all do
      class Caption
        include Mongoid::Document
        include Mongoid::Slug

        field :author
        field :title
        field :medium

        # A fairly complex scenario, where we want to create a slug out
        # of an author field, which comprises name of artist and some
        # more bibliographic info in parantheses, and the title of the work.
        #
        # We are only interested in the name of the artist so we remove the
        # paranthesized details.

        slug :author, :title do |doc|
          [
            doc.author.gsub(/\s*\([^)]+\)/, '').to_url,
            doc.title.to_url
          ].join('/')
        end
      end
    end

    let(:caption) do
      Caption.create(
        :author => 'Edward Hopper (American, 1882-1967)',
        :title    => 'Soir Bleu, 1914',
        :medium   => 'Oil on Canvas'
      )
    end

    it "generates a slug" do
      expect(caption.slug).to eq('edward-hopper/soir-bleu-1914')
    end

    it "updates the slug" do
      caption.title = 'Road in Maine, 1914'
      caption.save
      expect(caption.slug).to eq("edward-hopper/road-in-maine-1914")
    end

    it "does not change slug if slugged fields have changed but generated slug is identical" do
      caption.author = 'Edward Hopper'
      caption.save
      expect(caption.slug).to eq('edward-hopper/soir-bleu-1914')
    end

    it "finds by slug" do
      expect(Caption.find_by_slug(caption.slug)).to eql(caption)
    end

  end

  context "when slugged field contains non-ASCII characters" do

    let(:book) { Book.create(:title => "A thousand plateaus") }

    # it "slugs Cyrillic characters" do
    #   book.title = "Капитал"
    #   book.save
    #   book.slug.should eql "kapital"
    # end

    # it "slugs Greek characters" do
    #   book.title = "Ελλάδα"
    #   book.save
    #   book.slug.should eql "ellada"
    # end

    # it "slugs Chinese characters" do
    #   book.title = "中文"
    #   book.save
    #   book.slug.should eql 'zhong-wen'
    # end

    it "slugs non-ASCII Latin characters" do
      book.title = 'Paul Cézanne'
      book.save
      expect(book.slug).to eql 'paul-cezanne'
    end
  end

  describe ".find_by_slug" do
    let(:book) { Book.create(:title => "A Thousand Plateaus") }

    it "returns nil if no document is found" do
      expect(Book.find_by_slug(:title => "Anti Oedipus")).to be_nil
    end

    it "returns the document if it is found" do
      expect(Book.find_by_slug(book.slug)).to eq(book)
    end
  end

  describe ".find_by_slug!" do
    let(:book) { Book.create(:title => "A Thousand Plateaus") }

    it "raises a Mongoid::Errors::DocumentNotFound error if no document is found" do
      expect {
        Book.find_by_slug!(:title => "Anti Oedipus")
      }.to raise_error(Mongoid::Errors::DocumentNotFound)
    end

    it "returns the document when it is found" do
      expect(Book.find_by_slug!(book.slug)).to eq(book)
    end
  end

  # context "when #slug is called on an existing record with no slug" do

  #   before do
  #     Book.collection.insert(:title => "Proust and Signs")
  #   end

  #   it "generates the missing slug" do
  #     book = Book.first
  #     book.slug
  #     book.reload.slug.should == "proust-and-signs"
  #   end

  # end
end
