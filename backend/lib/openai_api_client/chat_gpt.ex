defmodule OpenaiApiClient.ChatGPT do
  @api_key System.get_env("OPENAI_API_KEY")

  @config Application.compile_env(:jump_start, :openai_api)
  @api_url "#{@config[:base_url]}/v1/chat/completions"

  def ask_question(question) do
    IO.puts("Asking LLM...")

    headers = [
      {"Authorization", "Bearer #{@api_key}"},
      {"Content-Type", "application/json"}
    ]

    body =
      Jason.encode!(%{
        "model" => "gpt-3.5-turbo",
        "messages" => [
          %{
            "role" => "user",
            "content" => question
          }
        ],
        "temperature" => 0.7
      })

    case HTTPoison.post(@api_url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
        {:ok, parsed} = Jason.decode(response_body)
        {:ok, get_in(parsed, ["choices", Access.at(0), "message", "content"])}

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "API request failed with status #{status_code}: #{body}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{reason}"}
    end
  end
end
