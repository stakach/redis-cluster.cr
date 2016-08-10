require "./spec_helper"

private def bootstrap(host, port, pass = nil)
  Redis::Cluster::Bootstrap.new(host, port, pass)
end

private def parse(string) : Redis::Cluster::Bootstrap
  Redis::Cluster::Bootstrap.parse(string)
end

describe Redis::Cluster::Bootstrap do
  describe "equality" do
    it "should test by value" do
      bootstrap("a",1).should eq(bootstrap("a",1))
      bootstrap("a",1).should_not eq(bootstrap("a",2))
      bootstrap("a",1).should_not eq(bootstrap("b",1))

      bootstrap("a",1,"p").should eq(bootstrap("a",1,"p"))
      bootstrap("a",1,"p").should_not eq(bootstrap("a",1))
      bootstrap("a",1,"p").should_not eq(bootstrap("a",2,"p"))
      bootstrap("a",1,"p").should_not eq(bootstrap("b",1,"p"))
    end
  end

  describe ".parse" do
    it "should treat a empty host as 127.0.0.1" do
      parse(":7001").host.should eq("127.0.0.1")
    end

    it "should treat a empty port as 6379" do
      parse("localhost").port.should eq(6379)
    end

    it "should treat a empty password as is" do
      parse("localhost:6379").pass.should eq(nil)
    end

    it "should build default setting from empty string" do
      parse("").should eq(bootstrap("127.0.0.1", 6379, nil))
    end

    it "should accept uri with protocol" do
      parse("redis://a@host:1").should eq(bootstrap("host"     , 1   , "a"))
      parse("redis://a@host:1").should eq(bootstrap("host"     , 1   , "a"))
      parse("redis://a@host"  ).should eq(bootstrap("host"     , 6379, "a"))
      parse("redis://a@:1"    ).should eq(bootstrap("127.0.0.1", 1   , "a"))
      parse("redis://host:1"  ).should eq(bootstrap("host"     , 1   , nil))
      parse("redis://host"    ).should eq(bootstrap("host"     , 6379, nil))
      parse("redis://a@"      ).should eq(bootstrap("127.0.0.1", 6379, "a"))
      parse("redis://:1"      ).should eq(bootstrap("127.0.0.1", 1   , nil))
    end

    it "should accept uri without protocol" do
      parse("a@host:1").should eq(bootstrap("host"     , 1   , "a"))
      parse("a@host:1").should eq(bootstrap("host"     , 1   , "a"))
      parse("a@host"  ).should eq(bootstrap("host"     , 6379, "a"))
      parse("a@:1"    ).should eq(bootstrap("127.0.0.1", 1   , "a"))
      parse("host:1"  ).should eq(bootstrap("host"     , 1   , nil))
      parse("host"    ).should eq(bootstrap("host"     , 6379, nil))
      parse("a@"      ).should eq(bootstrap("127.0.0.1", 6379, "a"))
      parse(":1"      ).should eq(bootstrap("127.0.0.1", 1   , nil))
    end

    it "should raise when port part is not number nor positive" do
      expect_raises(Exception, /port/) do
        parse("127.0.0.1:x")
      end

      expect_raises(Exception, /port/) do
        parse("127.0.0.1:0")
      end

      expect_raises(Exception, /port/) do
        parse("127.0.0.1:-1")
      end
    end

    it "should raise when non 'redis' schema is given" do
      expect_raises(Exception, /scheme/) do
        parse("http://127.0.0.1")
      end
    end
  end
end
