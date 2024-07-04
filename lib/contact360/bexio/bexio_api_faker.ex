defmodule Contact360.Bexio.BexioApiFaker do
  @moduledoc """
  This module is responsible for faking the Bexio API in case of tests or offline access.
  """

  def new(_) do
    %{}
  end

  defmodule Contacts do
    @moduledoc false
    def fetch_contact_groups(_client),
      do:
        {:ok,
         %{
           93 => "A",
           78 => "I"
         }}
  end

  defmodule Accounting do
    @moduledoc false
    def fetch_accounts(_client),
      do:
        {:ok,
         [
           %BexioApiClient.Accounting.Account{
             id: 90,
             account_no: 9900,
             name: "Korrekturen",
             account_group_id: 68,
             account_type: :complete_account,
             tax_id: nil,
             active?: true,
             locked?: true
           },
           %BexioApiClient.Accounting.Account{
             id: 93,
             account_no: 9100,
             name: "Eröffnungsbilanz",
             account_group_id: 68,
             account_type: :complete_account,
             tax_id: nil,
             active?: true,
             locked?: true
           }
         ]}
  end

  defmodule Others do
    @moduledoc false
    def fetch_company_profiles(_req) do
      {:ok,
      [
        %BexioApiClient.Others.CompanyProfile{
          id: 1,
          name: "Testing Company AG",
          address: "Irgendwo 99",
          address_nr: "",
          postcode: "9999",
          city: "Unter dem Monde",
          country_id: 1,
          legal_form: :corporation,
          country_name: "Schweiz",
          mail: "",
          phone_fixed: "",
          phone_mobile: "",
          fax: "",
          url: "",
          skype_name: "",
          facebook_name: "",
          twitter_name: "",
          description: "",
          ust_id_nr: "CHE-123.456.789",
          mwst_nr: "CHE-123.456.789 MWST",
          trade_register_nr: nil,
          own_logo?: true,
          public_profile?: false,
          logo_public?: false,
          address_public?: false,
          phone_public?: false,
          mobile_public?: false,
          fax_public?: false,
          mail_public?: false,
          url_public?: false,
          skype_public?: false,
          logo_base64: nil
        }
      ]}    end

    def get_access_information(_req) do
      {:ok,
       %BexioApiClient.Others.Permission{
         components: [
           "api2_access",
           "api3_access",
           "bill_administration",
           "admin",
           "user_administration",
           "vat_settings_pro",
           "global_search",
           "communication_center",
           "billing_discount_existingcustomers",
           "fm",
           "accountant_management",
           "addon_management",
           "company_user_management",
           "payment_method",
           "reminder_pro",
           "exchange_rates_management",
           "payment_services_management",
           "kb_client_account_management",
           "export_settings_export_sales",
           "export_settings_export_products",
           "export_settings_export_tasks",
           "sales_wizard_other",
           "analytics",
           "file_upload",
           "contact",
           "todo",
           "history",
           "project",
           "project_show_conditions",
           "article",
           "monitoring",
           "stockmanagement",
           "stockmanagement_changes",
           "dashboard_widget_sales",
           "banking",
           "banking_sync",
           "banking_direct",
           "banking_ubs_camt",
           "banking_kbag_blink",
           "banking_kbsz_blink",
           "banking_vabe_blink",
           "accounting_reports",
           "kb_offer",
           "kb_order",
           "kb_invoice",
           "kb_credit_voucher",
           "kb_delivery",
           "kb_account_statement",
           "expense",
           "kb_bill",
           "kb_article_order",
           "kb_wizard_recurring_invoices",
           "kb_wizard_payments",
           "kb_wizard_reminder",
           "kb_wizard_v11",
           "network",
           "document_designer",
           "manual_entries",
           "payroll",
           "vendor_credit_notes",
           "spa_bills",
           "spa_expenses"
         ],
         permissions: %{
           kb_bill: %{edit: :all, show: :all, activation: :enabled},
           writer: %{edit: :all, show: :all, activation: :enabled},
           article: %{edit: :all, show: :all, activation: :enabled},
           history: %{edit: :all, show: :all, activation: :enabled},
           marketing: %{edit: :all, show: :all, activation: :enabled},
           banking: %{edit: :all, activation: :enabled},
           kb_wizard_reminder: %{activation: :enabled},
           lean_sync: %{activation: :enabled},
           dashboard_widget_sales: %{activation: :enabled},
           bill_administration: %{activation: :enabled},
           document_designer: %{activation: :enabled},
           expense: %{edit: :all, show: :all, activation: :enabled},
           user_administration: %{activation: :enabled},
           kb_wizard_v11: %{activation: :enabled},
           file_upload: %{edit: :all, show: :all, activation: :enabled},
           banking_sync: %{activation: :enabled},
           accounting_reports: %{activation: :enabled},
           vendor_credit_notes: %{activation: :enabled},
           analytics: %{activation: :enabled, download: :all},
           gdrive: %{activation: :enabled},
           file_manager_share: %{activation: :enabled},
           kb_offer: %{edit: :all, show: :all, activation: :enabled},
           pingen: %{activation: :enabled},
           kb_delivery: %{edit: :all, show: :all, activation: :enabled},
           fm: %{activation: :enabled},
           project_show_conditions: %{activation: :enabled},
           kb_invoice: %{edit: :all, show: :all, activation: :enabled},
           calendar: %{edit: :all, show: :all, activation: :enabled},
           mailchimp: %{activation: :enabled},
           kb_order: %{edit: :all, show: :all, activation: :enabled},
           project: %{edit: :all, show: :all, activation: :enabled},
           kb_wizard_recurring_invoices: %{activation: :enabled},
           boxnet: %{activation: :enabled},
           kb_wizard_payments: %{activation: :enabled},
           contact: %{edit: :all, show: :all, activation: :enabled},
           dropbox: %{activation: :enabled},
           stockmanagement_changes: %{edit: :all},
           kb_article_order: %{edit: :all, show: :all, activation: :enabled},
           file_manager: %{edit: :all, show: :all, activation: :enabled},
           kb_credit_voucher: %{edit: :all, show: :all, activation: :enabled},
           stockmanagement: %{edit: :all, show: :all, activation: :enabled},
           monitoring: %{edit: :all, show: :all, activation: :enabled},
           banking_direct: %{activation: :enabled},
           payroll: %{activation: :disabled},
           kb_account_statement: %{edit: :all, show: :all, activation: :enabled},
           todo: %{edit: :all, show: :all, activation: :enabled},
           admin: %{activation: :enabled}
         }
       }}
    end
  end
end
