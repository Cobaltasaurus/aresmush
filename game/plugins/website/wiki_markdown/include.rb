module AresMUSH
  module Website
    class IncludeMarkdownExtension
      def self.regex
        /\[\[include ([^\]]*)\]\]/i
      end
      
      def self.parse(matches, sinatra)
        input = matches[1]
        return "" if !input

        error_message = "<div class=\"alert alert-danger\">There was a problem including #{input}.  Make sure the page exists and all required variables are set.</div>"
        
        begin          
          vars = {}
          
          page_name = input.before("\n").strip.downcase
          split_vars = (input.after("\n") || "").split("|")
          split_vars.each do |v|
            var_name = v.before('=')
            var_val = v.after('=')
            if (var_name && var_val)
              vars[var_name.strip.downcase.to_sym] = var_val.strip
            end
          end

          page = WikiPage.find_by_name_or_id(page_name)
          if (!page)
            return error_message
          end
                    
          text = page.current_version.text % vars

        rescue Exception => ex
          Global.logger.debug "Error loading include #{input} : #{ex}"
          return error_message
        end
      end
    end
  end
end
