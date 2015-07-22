module IStats
  class Settings
    require 'parseconfig'
    @configFile="sensors.conf"
    @configDir=File.expand_path("~/.iStats")+"/"

    class << self

      def delegate(stat)
        
        case stat[0]
        when 'enable'
          if (stat[1] == 'all')
            toggleAll("1")
          else
            set(stat[1],"1")
          end
        when 'disable'
          if (stat[1] == 'all')
            toggleAll("0")
          else
            set(stat[1],"0")
          end
        else
          puts "Unknown command"
        end
      end


      def load
        if File.exists?( @configDir+@configFile )
          $config = ParseConfig.new(@configDir+@configFile)
        else
           sensors=Hash.new
           sensors['thresholds'] = "[50, 68, 80, 90]"
           name="CPU Proximity"
           sensors['name']=name
           sensors['enabled']="1"
           key="TC0P"
           $config =ParseConfig.new
           $config.add(key,sensors)
        end
      end

      def configFileExists
         if File.exists?( @configDir+@configFile )
          $config = ParseConfig.new(@configDir+@configFile)
        else
          puts "No config file #{@configDir}#{@configFile} found .. Run scan"
          if !File.exists?(@configDir)
            Dir.mkdir( @configDir)
          end
          file=File.open(@configDir+@configFile,"w+")
          file.close
        end
      end
  
      def addSensor(key,sensors)
        settings = ParseConfig.new(@configDir+@configFile)
        settings.add(key,sensors)
        file = File.open(@configDir+@configFile,'w')
        settings.write(file)
        file.close
      end
      
      def set(key,value)
        configFileExists
        settings = ParseConfig.new(@configDir+@configFile)
        sensors =settings.params
        if (sensors[key])
          sensors[key]['enabled']=value
        else
          puts "Not valid key"
        end
        file = File.open(@configDir+@configFile,'w')
        settings.write(file)
        file.close
      end
      
      def toggleAll(value)
        if File.exists?( @configDir+@configFile )
          settings = ParseConfig.new(@configDir+@configFile)
          settings.params.keys.each{|key|
            settings.params[key]['enabled']=value
            }
          file = File.open(@configDir+@configFile,'w')
          settings.write(file)
          file.close
        else
          puts "Run 'istats scan' first"
        end
      end
      
      def list
        if File.exists?( @configDir+@configFile )
          settings = ParseConfig.new(@configDir+@configFile)
          settings.params.keys.each{|key|
            puts key+" => "+SMC.name(key)+" Enabled = "+settings[key]['enabled']
            }
        else
          puts "Run 'istats scan' first"
        end
      end
      
    end
  end
end