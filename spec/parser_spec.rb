require File.join(File.dirname(__FILE__), 'spec_helper')

describe Relief::Parser do
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
      elements :photo do
        attribute :name
        attribute :url
      end
    end

    photos = parser.parse(<<-XML)
      <?xml version="1.0" encoding="UTF-8"?>
      <photos>
        <photo name="Cucumbers" url="/photos/cucumbers.jpg" />
        <photo name="Lemons" url="/photos/lemons.jpg" />
      </photos>
    XML

    photos.should == {
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
      element :published, :type => Date
    end

    photo = parser.parse(<<-XML)
      <?xml version="1.0" encoding="UTF-8"?>
      <photo>
        <id>86634</id>
        <rating>3.5</rating>
        <published>2009-05-08T18:23:26-07:00</url>
      </photo>
    XML

    photo.should == {
      :id => 86634,
      :rating => 3.5,
      :published => Date.parse('2009-05-08T18:23:26-07:00')
    }
  end
end
