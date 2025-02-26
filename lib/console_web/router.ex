defmodule ConsoleWeb.Router do
  use ConsoleWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug ConsoleWeb.Plug.RateLimit, ["browser_actions", 60]
    plug ConsoleWeb.Plug.CheckDomain
    plug ConsoleWeb.Plug.VerifyRemoteIpRange
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug ConsoleWeb.Plug.RateLimit, ["auth_actions", 60]
    plug ConsoleWeb.Plug.CheckDomain
    plug ConsoleWeb.Plug.VerifyRemoteIpRange
  end

  pipeline :router_api do
    plug :accepts, ["json"]
    plug ConsoleWeb.Plug.RateLimit, ["router_auth_actions", 10]
    plug ConsoleWeb.Plug.VerifyRemoteIpRange
  end

  scope "/graphql" do
    pipe_through ConsoleWeb.Plug.GraphqlPipeline

    forward "/", Absinthe.Plug, schema: ConsoleWeb.Schema
  end

  scope "/api", ConsoleWeb do
    pipe_through :api

    get "/invitations/:token", InvitationController, :get_by_token
    post "/subscribe_new_user", Auth0Controller, :subscribe_new_user
    post "/sessions", SessionController, :create
    post "/sessions/check_user", SessionController, :check_user
    post "/sessions/verify_recaptcha", SessionController, :verify_recaptcha
    post "/resend_invitation/:email", InvitationController, :resend_invitation
  end

  scope "/api", ConsoleWeb do
    pipe_through ConsoleWeb.AuthApiPipeline

    post "/users", InvitationController, :accept, as: "user_join_from_invitation"
    resources "/devices", DeviceController, except: [:index, :new, :edit]
    post "/devices/delete", DeviceController, :delete
    post "/devices/set_active", DeviceController, :set_active
    get "/devices/:device_id/events", DeviceController, :get_events
    get "/ttn/devices", DeviceController, :get_ttn
    post "/ttn/devices/import", DeviceController, :import_ttn
    post "/generic/devices/import", DeviceController, :import_generic
    post "/devices/remove_config_profiles", DeviceController, :remove_config_profiles
    resources "/labels", LabelController, only: [:create, :update, :delete]
    post "/labels/swap_label", LabelController, :swap_label
    resources "/alerts", AlertController, only: [:create, :delete, :update]
    post "/alerts/add_to_node", AlertController, :add_alert_to_node
    post "/alerts/remove_from_node", AlertController, :remove_alert_from_node
    resources "/packet_configs", PacketConfigController, only: [:create, :delete, :update]
    post "/packet_configs/add_to_node", PacketConfigController, :add_packet_config_to_node
    post "/packet_configs/remove_from_node", PacketConfigController, :remove_packet_config_from_node
    resources "/channels", ChannelController, except: [:index, :new, :edit]
    resources "/organizations", OrganizationController, except: [:new, :edit, :show]
    post "/channels/ubidots", ChannelController, :get_ubidots_url
    post "/channels/google_sheets", ChannelController, :get_google_form_data
    get "/mfa_enrollments", Auth0Controller, :get_enrolled_mfa
    post "/mfa_enrollments", Auth0Controller, :enroll_in_mfa
    delete "/mfa_enrollments", Auth0Controller, :disable_mfa
    post "/devices_labels", LabelController, :add_devices_to_label
    post "/devices_labels/delete", LabelController, :delete_devices_from_labels
    resources "/config_profiles", ConfigProfileController, only: [:create, :delete, :update]
    post "/config_profiles/add_to_node", ConfigProfileController, :add_config_profile_to_node
    post "/config_profiles/remove_from_node", ConfigProfileController, :remove_config_profile_from_node
    post "/hotspot_group", GroupController, :add_hotspot_to_group
    post "/delete_hotspot_group", GroupController, :remove_hotspot_from_group
    resources "/groups", GroupController, only: [:create, :delete, :update]

    resources "/invitations", InvitationController, only: [:create, :delete]
    resources "/memberships", MembershipController, only: [:update, :delete]

    resources "/api_keys", ApiKeyController, only: [:create, :delete]
    resources "/functions", FunctionController, only: [:create, :delete, :update]

    post "/data_credits/create_customer_and_charge", DataCreditController, :create_customer_id_and_charge
    post "/data_credits/create_charge", DataCreditController, :create_charge
    get "/data_credits/payment_methods", DataCreditController, :get_payment_methods
    get "/data_credits/setup_payment_method", DataCreditController, :get_setup_payment_method
    post "/data_credits/set_default_payment_method", DataCreditController, :set_default_payment_method
    post "/data_credits/remove_payment_method", DataCreditController, :remove_payment_method
    post "/data_credits/create_dc_purchase", DataCreditController, :create_dc_purchase
    post "/data_credits/set_automatic_payments", DataCreditController, :set_automatic_payments
    post "/data_credits/transfer_dc", DataCreditController, :transfer_dc
    get "/data_credits/generate_memo", DataCreditController, :generate_memo
    get "/data_credits/router_address", DataCreditController, :get_router_address
    get "/data_credits/get_hnt_price", DataCreditController, :get_hnt_price

    post "/flows/update", FlowsController, :update_edges

    post "/downlink", DownlinkController, :send_downlink
    post "/clear_downlink_queue", DownlinkController, :clear_downlink_queue
    get "/downlink_queue", DownlinkController, :fetch_downlink_queue

    post "/organization_hotspot", OrganizationHotspotController, :update_organization_hotspot
    post "/organization_hotspots", OrganizationHotspotController, :update_organization_hotspots

    get "/organizations/export", OrganizationController, :export
    post "/organizations/import", OrganizationController, :import
    # post "/organizations/survey", OrganizationController, :submitted_survey
    # post "/organizations/survey_token", OrganizationController, :submit_survey_token
    # post "/organizations/survey_token/resend", OrganizationController, :resend_survey_token
  end

  scope "/api/router", ConsoleWeb.Router do
    pipe_through :router_api

    post "/sessions", SessionController, :create
    post "/sessions/refresh", SessionController, :refresh
  end

  scope "/api/router", ConsoleWeb.Router do
    pipe_through ConsoleWeb.RouterApiPipeline

    get "/devices/unknown", DeviceController, :get_by_other_creds
    get "/devices/:id", DeviceController, :show
    resources "/devices", DeviceController, only: [:index] do
      post "/event", DeviceController, :add_device_event
    end
    post "/devices/update_in_xor_filter", DeviceController, :update_devices_in_xor_filter
    resources "/organizations", OrganizationController, only: [:index, :show]
    post "/organizations/burned", OrganizationController, :burned_dc
    post "/organizations/manual_update_router_dc", OrganizationController, :manual_update_router_dc
  end

  scope "/api/v1", ConsoleWeb.V1 do
    pipe_through :api

    post "/down/:channel_id/:downlink_token/:device_id", DownlinkController, :down
    post "/down/:channel_id/:downlink_token", DownlinkController, :down
  end

  scope "/api/v1", ConsoleWeb.V1 do
    pipe_through ConsoleWeb.V1ApiPipeline

    get "/organization", OrganizationController, :show
    put "/devices/active", DeviceController, :set_devices_active
    resources "/devices", DeviceController, only: [:index, :show, :create, :delete, :update]
    get "/devices/:device_id/events", DeviceController, :get_events
    resources "/labels", LabelController, only: [:index, :show, :create, :delete, :update]
    put "/labels/:label_id/active", LabelController, :set_devices_active
    post "/devices/:device_id/labels", LabelController, :add_device_to_label
    delete "/devices/:device_id/labels/:label_id", LabelController, :delete_device_from_label
    post "/devices/discover", DeviceController, :discover_device
    resources "/functions", FunctionController, only: [:index, :show, :create, :delete, :update]
    resources "/alerts", AlertController, only: [:create, :update, :delete]
    post "/alerts/add_to_node", AlertController, :add_alert_to_node
    post "/alerts/remove_from_node", AlertController, :remove_alert_from_node
    resources "/integrations", ChannelController, only: [:index, :create, :show, :delete]
    post "/integrations/community", ChannelController, :create_community_channel
    resources "/flows", FlowController, only: [:index, :create, :delete]
  end

  if Mix.env == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  scope "/", ConsoleWeb do
    pipe_through :browser # Use the default browser stack

    get "/invitations/accept/:token", InvitationController, :redirect_to_register, as: "accept_invitation"
    get "/invitations/:email", InvitationController, :get_by_email
    get "/api_keys/accept/:token", ApiKeyController, :accept, as: "accept_api_key"
    get "/google14b344de8ed0f4f1.html", PageController, :google_verify

    get "/*path", PageController, :index
  end
end
