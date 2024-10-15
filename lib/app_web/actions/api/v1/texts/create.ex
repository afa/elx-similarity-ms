defmodule Api.V1.Texts.Create do
  def call(identifier, %{name: name, text: text, models: models}) do
    {:ok, %{ids: []}}
  end
end
