defmodule Example.ErrorHelpers do
  def translate_error({msg, opts}) do
    if count = opts[:count] do
      Gettext.dngettext(Example.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(Example.Gettext, "errors", msg, opts)
    end
  end
end
