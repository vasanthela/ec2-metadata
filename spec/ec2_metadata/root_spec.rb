require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Ec2Metadata::Root do

  describe :[] do
    before do
      @root = Ec2Metadata::Root.new
    end

    REVISIONS.each do |rev|
      it "should return Revision for #{rev}" do
        Ec2Metadata.should_receive(:get).with("/").once.
          and_return(REVISIONS.join("\n"))
        revision = @root[rev]
        revision.class.should == Ec2Metadata::Revision
      end
    end

    it "should return latest DataType for user-data" do
      Ec2Metadata.should_receive(:get).with("/").once.
        and_return(REVISIONS.join("\n"))
      Ec2Metadata.should_receive(:get).with("/latest/").once.
        and_return(DATA_TYPES.join("\n"))
      Ec2Metadata.should_receive(:get).with("/latest/user-data").once.
        and_return("test-user-data1")
      obj = @root['user-data']
      obj.should == "test-user-data1"
    end

    it "should return latest DataType for meta-data" do
      Ec2Metadata.should_receive(:get).with("/").once.
        and_return(REVISIONS.join("\n"))
      Ec2Metadata.should_receive(:get).with("/latest/").once.
        and_return(DATA_TYPES.join("\n"))
      Ec2Metadata.should_not_receive(:get).with("/latest/meta-data/")
      obj = @root['meta-data']
      obj.class.should == Ec2Metadata::Base
    end
  end
  
end
