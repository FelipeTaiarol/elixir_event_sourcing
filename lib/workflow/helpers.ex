defmodule Workflows.Helpers do
  def log(a, text) do
    IO.puts("#{text} #{inspect(a)}")
    a
  end
end
