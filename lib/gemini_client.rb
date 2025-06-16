require "httparty"
require "json"

class GeminiClient
  API_KEY = ENV["GEMINI_API_KEY"]
  MODEL = "gemini-2.5-flash-preview-05-20" # "gemini-2.0-flash"

  def initialize(user_prompt:, system_prompt: nil, return_schema: nil)
    @user_prompt = user_prompt
    @system_prompt = system_prompt
    @return_schema = return_schema
  end

  def generate_content
    # return offline_data

    puts "Generating request"
    @response ||= HTTParty.post(
      "https://generativelanguage.googleapis.com/v1beta/models/#{MODEL}:generateContent?key=#{API_KEY}",
      headers: {"Content-Type" => "application/json"},
      body: request_body.to_json
    )
    puts "Parsing response...."

    if @response["error"]
      raise "Error generating content: #{@response["error"]["message"]}"
    else
      answer = @response["candidates"].first.dig("content", "parts").first["text"]

      if @return_schema
        begin
          JSON.parse(answer)
        rescue JSON::ParserError => e
          raise "Failed to parse response as JSON: #{e.message}. Response was: #{answer}"
        end
      else
        answer
      end
    end
  end

  # example usage: GeminiClient.generate_activity_suggestion(stats, time_investment: "3 hours", account_type: :ironman, intensity: :medium)
  def self.generate_activity_suggestion(user_stats, time_investment: nil, account_type: :main, intensity: nil)
    system_prompt = <<~PROMPT
      You are a helpful assistant that suggests activities in the video game Old School Runescape based on a provided player's stats.
      You will be provided a JSON object containing the player's stats, including their current level in each skill, their total level, their total experience, their killcount in various bosses, their account type, and how much time they want to spend on this activity.
      Your goal is to provide 2-4 activities that will progress the player's account in a meaningful way or makes them money, while also being enjoyable for the player.
      Assume the player is relatively experienced when building your suggestions, and that they are not a new player. Make sure to add some variety too.
    PROMPT

    new(
      system_prompt: system_prompt,
      user_prompt: {
        stats: user_stats,
        desired_time_investment: time_investment,
        account_type: account_type,
        intensity: intensity
      }.to_json,
      return_schema: {
        type: "ARRAY",
        items: {
          type: "OBJECT",
          properties: {
            activityName: {type: "STRING"},
            description: {type: "STRING"},
            timeInvestment: {type: "STRING"},
            intensity: {type: "STRING"},
            profit: {type: "STRING"},
            requirements: {
              type: "ARRAY",
              items: {type: "STRING"}
            }
          }
        }
      }
    ).generate_content
  end

  # TODO: Update response
  def offline_data
    [{"activityName" => "Tombs of Amascut (ToA)",
      "description" =>
     "Engage in the challenging Tombs of Amascut raid. With your high combat stats, you're well-equipped to tackle higher invocations and chase powerful unique items like the Shadow of Tumeken, Masori armour, and Lightbearer/Ultor ring components. This is a crucial step for endgame ironman progression.",
      "intensity" => "High",
      "profit" => "Extremely High (unique BIS gear and supplies)",
      "benefits" => [],
      "requirements" => ["High combat stats (met)", "Basic understanding of raid mechanics"],
      "timeInvestment" => "3 hours"},
      {"activityName" => "Vardorvis (Desert Treasure II Boss)",
       "description" =>
        "Challenge Vardorvis, one of the new Desert Treasure II bosses. This boss drops the Ultor Vestige (component for the best-in-slot strength ring) and Bellator Vestige. It's a high-intensity boss that offers excellent combat experience and is a key step towards ultimate endgame gear.",
       "intensity" => "High",
       "profit" => "Extremely High (unique BIS ring components)",
       "benefits" => [],
       "requirements" => ["Completion of Desert Treasure II quest (highly recommended)", "High combat stats (met)"],
       "timeInvestment" => "3 hours"},
      {"activityName" => "Hallowed Sepulchre",
       "description" =>
        "Continue your Agility training at the Hallowed Sepulchre. This activity is the best Agility XP in the game at high levels and provides a consistent flow of Hallowed Marks (for crystal items and prayer XP) and profitable artifacts. It's highly engaging and requires sustained focus.",
       "intensity" => "High",
       "profit" => "High (Hallowed Marks, prayer XP, GP from artifacts)",
       "benefits" => [],
       "requirements" => ["91 Agility (met)", "72 Thieving for full access (met)"],
       "timeInvestment" => "3 hours"},
      {"activityName" => "Phantom Muspah",
       "description" =>
        "Tackle the Phantom Muspah, a hybrid boss providing valuable unique drops like the Venator Bow and Ancient Sceptre components. It's a fantastic source of consistent prayer and combat experience, along with a good stream of scales and other useful supplies for an ironman account.",
       "intensity" => "High",
       "profit" => "High (unique items, scales, prayer XP, general supplies)",
       "benefits" => [],
       "requirements" => ["Completion of Secrets of the North quest", "High combat stats (met)"],
       "timeInvestment" => "3 hours"}]
  end

  private

  def system_instruction
    return nil unless @system_prompt

    {
      parts: [
        {
          text: @system_prompt
        }
      ]
    }
  end

  def contents
    {
      parts: [
        {
          text: @user_prompt
        }
      ]
    }
  end

  def generation_config
    return nil unless @return_schema
    {
      responseMimeType: "application/json",
      responseSchema: @return_schema
    }
  end

  def request_body
    base = {contents: contents}

    base[:system_instruction] = system_instruction unless system_instruction.nil?
    base[:generationConfig] = generation_config unless generation_config.nil?

    base
  end
end
