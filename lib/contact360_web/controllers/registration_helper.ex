defmodule Contact360Web.RegistrationHelper do
  @moduledoc """
  Helper functions for the registration process
  """

  use Contact360Web, :live_component

  def registration_header(assigns) do
    ~H"""
    <div class="mx-auto max-w-7xl px-6 lg:px-8">
      <div class="mx-auto max-w-2xl lg:mx-0">
        <h2 class="text-4xl font-bold tracking-tight text-gray-900 dark:text-white sm:text-6xl">
          <%= gettext("Registrierung") %>
        </h2>
        <p class="mt-6 text-lg leading-8 text-gray-600 dark:text-gray-300">
          <%= gettext(
            "Hier finden Sie alle wichtigen Informationen zum Ablauf der Registrierung, welche Daten in der Applikation gespeichert werden, wie oft die Daten synchronisiert werden sowie oft gestellte Fragen."
          ) %>
        </p>
      </div>
    </div>
    """
  end

  def faq(assigns) do
    ~H"""
    <div class="mx-auto max-w-7xl px-6 py-24 sm:py-32 lg:px-8 lg:py-40">
      <div class="mx-auto max-w-4xl divide-y divide-gray-900/10 dark:divide-white/10">
        <h2 class="text-2xl font-bold leading-10 tracking-tight text-gray-900 dark:text-white">
          <%= gettext("Häufig gestellte Fragen") %>
        </h2>
        <dl class="mt-10 space-y-6 divide-y divide-gray-900/10 dark:divide-white/10">
          <div class="pt-6">
            <dt>
              <!-- Expand/collapse question button -->
              <button
                type="button"
                class="flex w-full items-start justify-between text-left text-gray-900 dark:text-white"
                aria-controls="faq-0"
                aria-expanded="false"
              >
                <span class="text-base font-semibold leading-7">
                  <%= gettext("Kann ich meine Daten wieder löschen lassen?") %>
                </span>
                <span class="ml-6 flex h-7 items-center">
                  <!--
                    Icon when question is collapsed.

                    Item expanded: "hidden", Item collapsed: ""
                  -->
                  <svg
                    class="hidden h-6 w-6"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke-width="1.5"
                    stroke="currentColor"
                    aria-hidden="true"
                  >
                    <path stroke-linecap="round" stroke-linejoin="round" d="M12 6v12m6-6H6" />
                  </svg>
                  <!--
                    Icon when question is expanded.

                    Item expanded: "", Item collapsed: "hidden"
                  -->
                  <svg
                    class="h-6 w-6"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke-width="1.5"
                    stroke="currentColor"
                    aria-hidden="true"
                  >
                    <path stroke-linecap="round" stroke-linejoin="round" d="M18 12H6" />
                  </svg>
                </span>
              </button>
            </dt>
            <dd class="mt-2 pr-12" id="faq-0">
              <p class="text-base leading-7 text-gray-600 dark:text-gray-300">
                <%= gettext(
                  "Wenn man seinen Account schliesst, werden sämtliche gespeicherte Daten gelöscht und müssen bei einer erneuten Anmeldung auch wieder komplett synchronisiert werden."
                ) %>
              </p>
            </dd>
          </div>
        </dl>
      </div>
    </div>
    """
  end
end
