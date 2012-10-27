module AresMUSH
  class Dispatcher

    def initialize(system_manager)
      @system_manager = system_manager
    end

    def on_player_command(client, cmd)
      handled = false
      begin
        logger.debug("Player command: client=#{client.id} cmd=#{cmd}")
        @system_manager.systems.each do |s|
          if (s.respond_to?(:on_player_command))
            s.commands.each do |cmd_regex|
              match = /^#{cmd_regex}/.match(cmd)
              if (!match.nil?)
                s.on_player_command(client, match)
                handled = true
              end
            end
          end
        end 
      rescue Exception => e
        # TODO - Clean up message
        logger.warn("Error handling command: client=#{client.id} cmd=#{cmd} error=#{e}")
        client.emit_failure "Bad code did badness! #{e}"
      end
      if (!handled)
        client.emit_ooc t('huh')
      end
    end

    def on_event(type, *args)
      begin
        @system_manager.systems.each do |s|
          if (s.respond_to?(:"on_#{type}"))
            s.send(:"on_#{type}", *args)
          end
        end
      rescue Exception => e
        # TODO - Clean up message
        logger.warn("Error handling event: event=#{type} error=#{e} args=#{args}")
      end
    end
  end
end