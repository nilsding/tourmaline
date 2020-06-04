module Tourmaline
  # Filters messages containing a specfic inline query callback.
  #
  # Options:
  # - `callback : String | Regex` - string or regex to match
  #
  # Context additions:
  # - `match : Regex::MatchData` - the match data returned by the successful match
  #
  # Example:
  # ```crystal
  # filter = InlineQueryFilter.new(/^foo(\d+)/)
  # ```
  class InlineQueryFilter < Filter
    property callback : Regex?

    def initialize(callback : (String | Regex)? = nil)
      case callback
      when Regex
        @callback = callback
      when String
        @callback = Regex.new("^#{Regex.escape(callback)}$")
      else
        @callback = nil
      end
    end

    def exec(client : Client, update : Update) : Bool
      if inline_query = update.inline_query
        return true unless @callback
        if inline_query.query.match(@callback.not_nil!)
          update.set_context({ query: inline_query.query })
          return true
        end
      end
      false
    end
  end
end
