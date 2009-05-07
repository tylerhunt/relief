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
end
