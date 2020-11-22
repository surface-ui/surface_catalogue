defmodule Surface.Components.Form.Example do
  use Surface.LiveView

  @moduledoc catalogue: [
               title: "Example #1",
               head: """
               <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bulma/0.8.2/css/bulma.min.css" />
               """,
               code: File.read!(__ENV__.file)
             ]

  alias Surface.Components.Form
  alias Surface.Components.Form.{TextInput, Label, Field}

  data user, :map, default: %{"name" => "", "email" => ""}

  def render(assigns) do
    ~H"""
    <Form for={{ :user }} change="change" submit="submit" opts={{ autocomplete: "off" }}>
      <Field class="field" name="name">
        <Label class="label"/>
        <div class="control">
          <TextInput class="input" value={{ @user["name"] }}/>
        </div>
      </Field>
      <Field class="field" name="email">
        <Label class="label">E-mail</Label>
        <div class="control">
          <TextInput class="input" value={{ @user["email"] }}/>
        </div>
      </Field>
    </Form>

    <pre>@user = {{ Jason.encode!(@user, pretty: true) }}</pre>
    """
  end

  def handle_event("change", %{"user" => params}, socket) do
    {:noreply, assign(socket, :user, params)}
  end
end
