defmodule OpenaiEx do
  @moduledoc """
  `OpenaiEx` is an Elixir library that provides a community-maintained client for the OpenAI API.

  The library closely follows the structure of the [official OpenAI API client libraries](https://platform.openai.com/docs/api-reference)
  for [Python](https://github.com/openai/openai-python)
  and [JavaScript](https://github.com/openai/openai-node),
  making it easy to understand and reuse existing documentation and code.
  """
  @enforce_keys [:token]
  defstruct token: nil,
            organization: nil,
            beta: nil,
            base_url: "https://api.openai.com/v1",
            receive_timeout: 15_000,
            finch_name: OpenaiEx.Finch,
            _ep_path_mapping: &OpenaiEx._identity/1,
            _http_headers: nil

  @doc """
  Creates a new OpenaiEx struct with the specified token and organization.

  See https://platform.openai.com/docs/api-reference/authentication for details.
  """
  def new(token, organization \\ nil) do
    headers =
      [{"Authorization", "Bearer #{token}"}] ++
        if(is_nil(organization),
          do: [],
          else: [{"OpenAI-Organization", organization}]
        )

    %OpenaiEx{
      token: token,
      organization: organization,
      _http_headers: headers
    }
  end

  @doc """
  Create file parameter struct for use in multipart requests.

  OpenAI API has endpoints which need a file parameter, such as Files and Audio.
  This function creates a file parameter given a name (optional) and content or a local file path.
  """
  def new_file(name: name, content: content) do
    {name, content}
  end

  def new_file(path: path) do
    {path}
  end

  # Globals for internal library use, **not** for public use.

  @assistants_beta_string "assistants=v1"
  @doc false
  def with_assistants_beta(openai = %OpenaiEx{}) do
    {_old_headers, new_openai} =
      openai
      |> Map.put(:beta, @assistants_beta_string)
      |> Map.get_and_update(:_http_headers, fn headers ->
        {headers, headers ++ [{"OpenAI-Beta", @assistants_beta_string}]}
      end)

    new_openai
  end

  # Globals to allow slight changes to API
  # Not public, and with no guarantee that they will continue to be supported.

  @doc false
  def _identity(x), do: x

  @doc false
  def _with_ep_path_mapping(openai = %OpenaiEx{}, ep_path_mapping)
      when is_function(ep_path_mapping, 1) do
    openai |> Map.put(:_ep_path_mapping, ep_path_mapping)
  end

  # Globals for public use.

  def with_base_url(openai = %OpenaiEx{}, base_url) do
    openai |> Map.put(:base_url, base_url)
  end

  def with_receive_timeout(openai = %OpenaiEx{}, receive_timeout) do
    openai |> Map.put(:receive_timeout, receive_timeout)
  end

  def with_finch_name(openai = %OpenaiEx{}, finch_name) do
    openai |> Map.put(:finch_name, finch_name)
  end

  @doc false
  def list_query_fields() do
    [
      :after,
      :before,
      :limit,
      :order
    ]
  end
end
