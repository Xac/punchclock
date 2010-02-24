module PunchClock
  class Base
    include PunchClock::Reporting
    include ActiveRecordConnection
    include TimeTools
  
    attr_accessor :category
    attr_accessor :mode
  
    def initialize(options={})
      @hours_per_day   = CONFIG[:hours_per_day] || 8
      @growl_enabled   = CONFIG[:enable_growl]  || false
      @mode            = options[:mode]
    
      string  = "Clock Started"
      # Happens the first time you use punchclock
      if In.count == 0
        @category = Category.create(:name => "Uncategorized")
        self.in(:description => "Initial clock in.")
        string << "\nInitial clock in."
      else
        string << "\nYou are currently clocked #{in_or_out}"
      end
      
      @category ||= find_last_category
      notify string
    end
        
    # Create a new category
    def add_category(category_name)
      category = Category.new(:name => category_name)
      if category.save
        notify "Created category: #{category_name}"
      else
        error_string = "Error creating category"
        unless category.valid?
          category.errors.each { |k,v| error_string << "\n#{k}: #{v}" }
        end
        notify error_string
      end
    end
  
    # Specify either the category id or category name
    def change_category(specified_category)
      category = find_category(specified_category)
      if category
        if clocked_in?
          out(:silent => true)
          sleep(1)
        end
        @category = category
        self.in(:description => "Category changed to #{category.name}", :silent => true)
        notify "Category changed to #{@category.name}"
      else
        # Give them the option to create the category if it doesn't exist
        if specified_category.is_a? String
          print "\nCould not find category '#{specified_category}', would you like to create it? [y/n]: "
          create_category = STDIN.gets.chomp!

          if create_category.upcase == 'Y'
            add_category(specified_category)
            change_category(specified_category)
          end
        else
          notify "Could not find category: #{specified_category}"
        end
      end
    end
  
    # List all categories with ids
    def categories
      notify Category.all(:order => "name ASC").collect {|c| c.name_with_id }.join("\n")
    end
  
    # Search for a category by name or id
    def find_category(specified_category)
      if specified_category.is_a?(String) || specified_category.is_a?(Symbol)
        Category.find_by_name(specified_category)
      else
        Category.find_by_id(category_id)
      end
    end
  
    # Clock in
    def in(options={})
      if clocked_in?
        notify "You are already clocked in."
      else
        In.create(:time => Time.now, :description => options[:description], :category => @category)
        notify "You are now clocked in." unless options[:silent]
      end
    end
  
    # Clock out
    def out(options={})
      if clocked_in?
        Out.create(:time => Time.now, :description => options[:description], :category => @category)
        notify "You are now clocked out." unless options[:silent]
      else
        notify "You are already clocked out." unless options[:silent]
      end
    end
  
    private
  
    # Last category used
    def find_last_category
      last_categorized_clock   = Out.last(:conditions => "category_id IS NOT NULL")
      last_categorized_clock ||= In.last(:conditions => "category_id IS NOT NULL")
    
      category = last_categorized_clock ? last_categorized_clock.category : Category.first
    end
      
    # Time of first clock in for the day
    def start_time_today
      In.find(:first, :conditions => ["time > '#{Date.today.beginning_of_day.to_s(:db)}'"], :order => "time ASC").time
    end
  
    # Most recent out record
    def last_out_time
      Out.last(:order => "time ASC").time rescue nil
    end

    # Most recent in record
    def last_in_time
      In.last(:order => "time ASC").time rescue nil
    end
    
    # Currently clocked in?
    def clocked_in?
      return false unless last_in_time
      
      last_out_time ? (last_in_time > last_out_time) : true
    end
  
    # Returns 'in' or 'out' depending on clocked status
    def in_or_out
      clocked_in? ? 'in' : 'out'
    end
  
    # Used to display message output
    def notify(msg)
      unless @mode.to_s.downcase == 'test'
        system "growlnotify --image '#{File.dirname(__FILE__)}/../../resources/clock.png' -m '#{msg}' Timeclock" if @growl_enabled

        puts msg
      end
    end
  end
end