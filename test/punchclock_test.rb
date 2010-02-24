require File.dirname(__FILE__) + '/test_helper'

class PunchclockTest < Test::Unit::TestCase
  context "A new punchclock" do
    setup do
      @clock = PunchClock::Base.new(:mode => :test)
    end
        
    # A new punchclock clocked out
    context "clocked out" do
      setup do
        @clock.out
      end

      context "when clocked in" do
        setup do
          @clock.in
        end

        should_change 'In.count', :by => 1
      end
    end
    
    # A new punchclock clocked in
    context "clocked in" do
      setup do
        @clock.in
      end

      # A new punchclock clocked in changing category
      context "changing category" do
        setup do
          @new_category = Category.create(:name => "Foo")
        end
        
        # A new punchclock clocked in changing category when category exists
        context "when category exists" do
          setup do
            @clock.change_category "Foo"
          end

          should_change 'Out.count', :by => 1
          should_change 'In.count', :by => 1
          
          should_change '@clock.instance_variable_get("@category").name', :to => "Foo"
        end

        # A new punchclock clocked in changing category when category doesn't exist
        context "when category doesn't exist" do
          setup do
            
          end

          should "description" do
            
          end
        end
      end
      

      # A new punchclock clocked in when clocked out
      context "when clocked out" do
        setup do
          @clock.out
        end

        should_change 'Out.count', :by => 1
      end
    end
  end
end
