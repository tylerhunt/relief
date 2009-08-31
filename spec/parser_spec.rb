require File.join(File.dirname(__FILE__), 'spec_helper')

describe Relief::Parser do
  it "raises a ParseError if the document can't be parsed" do
    parser = Relief::Parser.new(:photo) do
      element :name
      element :url
    end

    lambda {
      parser.parse('')
    }.should raise_error(Relief::ParseError)
  end

  it "parses elements" do
    parser = Relief::Parser.new(:photo) do
      element :name
      element :url
    end

    photo = parser.parse(<<-XML)
      <?xml version="1.0" encoding="UTF-8"?>
      <photo>
        <name>Cucumbers</name>
        <url>/photos/cucumbers.jpg</url>
      </photo>
    XML

    photo.should == { :name => 'Cucumbers', :url => '/photos/cucumbers.jpg' }
  end

  it "parses collections of elements" do
    parser = Relief::Parser.new(:photos) do
      elements :photo do
        element :name
        element :url
      end
    end

    photos = parser.parse(<<-XML)
      <?xml version="1.0" encoding="UTF-8"?>
      <photos>
        <photo>
          <name>Cucumbers</name>
          <url>/photos/cucumbers.jpg</url>
        </photo>
        <photo>
          <name>Lemons</name>
          <url>/photos/lemons.jpg</url>
        </photo>
      </photos>
    XML

    photos.should == {
      :photo => [
        { :name => 'Cucumbers', :url => '/photos/cucumbers.jpg' },
        { :name => 'Lemons', :url => '/photos/lemons.jpg' }
      ]
    }
  end

  it "parses attributes" do
    parser = Relief::Parser.new(:photos) do
      attribute :status

      elements :photo do
        attribute :name
        attribute :url
      end
    end

    photos = parser.parse(<<-XML)
      <?xml version="1.0" encoding="UTF-8"?>
      <photos status="fine">
        <photo name="Cucumbers" url="/photos/cucumbers.jpg" />
        <photo name="Lemons" url="/photos/lemons.jpg" />
      </photos>
    XML

    photos.should == {
      :status => 'fine',
      :photo => [
        { :name => 'Cucumbers', :url => '/photos/cucumbers.jpg' },
        { :name => 'Lemons', :url => '/photos/lemons.jpg' }
      ]
    }
  end

  it "parses elements by XPath" do
    parser = Relief::Parser.new(:photos) do
      elements '//photo', :as => :photo do
        element 'name/text()', :as => :name
        element 'url/text()', :as => :url
      end
    end

    photos = parser.parse(<<-XML)
      <?xml version="1.0" encoding="UTF-8"?>
      <photos>
        <photo>
          <name>Cucumbers</name>
          <url>/photos/cucumbers.jpg</url>
        </photo>
        <photo>
          <name>Lemons</name>
          <url>/photos/lemons.jpg</url>
        </photo>
      </photos>
    XML

    photos.should == {
      :photo => [
        { :name => 'Cucumbers', :url => '/photos/cucumbers.jpg' },
        { :name => 'Lemons', :url => '/photos/lemons.jpg' }
      ]
    }
  end

  it "parses elements by nested XPath" do
    parser = Relief::Parser.new(:photos) do
      elements '//name/text()', :as => :name
    end

    photos = parser.parse(<<-XML)
      <?xml version="1.0" encoding="UTF-8"?>
      <photos>
        <photo>
          <name>Cucumbers</name>
          <url>/photos/cucumbers.jpg</url>
        </photo>
        <photo>
          <name>Lemons</name>
          <url>/photos/lemons.jpg</url>
        </photo>
      </photos>
    XML

    photos.should == { :name => ['Cucumbers', 'Lemons'] }
  end

  it "parses elements with type casting" do
    parser = Relief::Parser.new(:photo) do
      element :id, :type => Integer
      element :rating, :type => Float
      element :taken, :type => Date
      element :modified, :type => Time
      element :published, :type => DateTime
    end

    photo = parser.parse(<<-XML)
      <?xml version="1.0" encoding="UTF-8"?>
      <photo>
        <id>86634</id>
        <rating>3.5</rating>
        <taken>2009-05-06</taken>
        <modified>2009-05-08T18:23:48-07:00</modified>
        <published>2009-05-08T18:23:26-07:00</published>
      </photo>
    XML

    photo.should == {
      :id => 86634,
      :rating => 3.5,
      :taken => Date.new(2009, 5, 6),
      :modified => Time.parse('2009-05-08T18:23:48-07:00'),
      :published => DateTime.new(2009, 5, 8, 18, 23, 26, Date.time_to_day_fraction(-7, 0, 0))
    }
  end

  it "parses elements with custom type casting" do
    author = Relief::Parser.new do
      element :name
      element :email
    end

    parser = Relief::Parser.new(:photo) do
      element :author, :type => author
    end

    photo = parser.parse(<<-XML)
      <?xml version="1.0" encoding="UTF-8"?>
      <photo>
        <author>
          <name>Jennifer Stone</name>
          <email>jstone@example.com</email>
        </author>
      </photo>
    XML

    photo.should == {
      :author => {
        :name => 'Jennifer Stone',
        :email => 'jstone@example.com'
      }
    }
  end

  it "doesn't type cast elements with empty values" do
    parser = Relief::Parser.new(:photo) do
      element :name
      element :id, :type => Integer
      element :rating, :type => Float
      element :taken, :type => Date
      element :published, :type => DateTime
    end

    photo = parser.parse(<<-XML)
      <?xml version="1.0" encoding="UTF-8"?>
      <photo>
        <name></name>
        <id></id>
        <rating></rating>
        <taken></taken>
        <published></published>
      </photo>
    XML

    photo.should == {
      :name => '',
      :id => nil,
      :rating => nil,
      :taken => nil,
      :published => nil
    }
  end
end
