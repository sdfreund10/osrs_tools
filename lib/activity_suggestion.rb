require_relative "gemini_client"

class ActivitySuggestion
  class InvalidPlayerError < StandardError; end

  attr_reader :player_name
  def initialize(player_name:, account_type: :main, intensity: nil)
    @player_name = player_name
    @account_type = account_type
    @intensity = intensity
  end

  def suggest_from_prompt(prompt, answer)
    GeminiClient.new(
      user_prompt: user_prompt.merge({additional_details: answer}).to_json,
      return_schema: gemini_schema,
      system_prompt: <<~PROMPT
        #{system_prompt}
        Additionally, the player was asked "#{prompt}" the answer to which was provided in the "additional_details" field. Ideally your response should build towards the goals described in the answer.
      PROMPT
    ).generate_content
  end

  def suggestions
    puts "Fetching suggestions for player: #{@player_name}, account type: #{@account_type}, intensity: #{@intensity}"
    GeminiClient.new(
      user_prompt: user_prompt.to_json,
      system_prompt: system_prompt,
      return_schema: gemini_schema
    ).generate_content
  end

  private

  def hiscore_data
    response = HTTParty.get("https://secure.runescape.com/m=hiscore_oldschool/index_lite.json?player=#{CGI.escape(player_name)}")
    if response.ok?
      response.body
    else
      raise InvalidPlayerError, "Failed to fetch player data for #{@player_name}. Response code: #{response.code}, message: #{response.message}"
    end
  end

  def offline_data
    JSON.parse(File.read(File.dirname(__FILE__) + "/stats.json"))
  end

  def gemini_schema
    {
      type: "ARRAY",
      items: suggestion_schema
    }
  end

  def suggestion_schema
    {
      type: "OBJECT",
      properties: {
        activityName: {type: "STRING"},
        description: {type: "STRING"},
        intensity: {type: "STRING", enum: ["Low", "Low-Medium", "Medium", "Medium-High", "High"]},
        benefits: {
          type: "ARRAY",
          items: {type: "STRING"}
        },
        requirements: {
          type: "ARRAY",
          items: {type: "STRING"}
        }
      }
    }
  end

  def system_prompt
    <<~PROMPT
      You are a helpful assistant that suggests activities in the video game Old School Runescape based on a provided player's stats.
      You will be provided a JSON object containing the player's stats, including their current level in each skill, their total level, their total experience, their killcount in various bosses, and their account type.
      Your goal is to provide 2-6 activities that will progress the player's account in a meaningful way or makes them money, while also being enjoyable for the player.
      Assume the player is relatively experienced when building your suggestions, and that they are not a new player. Make sure to add some variety too.
      Provide a description of the activity that is concise, ideally less than 20 words and describes the goal of the activity.
      Intensity is a subjective measure of how much effort the activity requires. High intensity activities may include bossing, PVP, or other high-risk activities that require a lot of attention and focus.
      Low intensity activities may include skilling, questing, or other low-risk activities that can be done while multitasking or relaxing.
      Please suggest activities with an intensity similar to the requested level.
      Return a list of benefits that the player will gain from doing the activity, such as "Train combat skills", "Earn money", "Unlock new gear".
    PROMPT
  end

  def user_prompt
    {
      stats: hiscore_data,
      account_type: @account_type,
      desired_intensity: @intensity
    }
  end
end
