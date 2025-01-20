# frozen_string_literal: true

describe Sessions::Services::Create do
  subject(:call) { described_class.new.call }

  before do
    stub_request(:post, "http://superset:8088/api/v1/security/login")
      .with(
        body:    {
          username: "admin",
          password: "admin",
          provider: "db",
          refresh:  true
        }.to_json,
        headers: {
          "Content-Type": "application/json"
        }
      )
      .to_return(
        status:  200,
        body:    { access_token: "fake_token" }.to_json,
        headers: { "Content-Type": "application/json" }
      )

    stub_request(:get, "http://superset:8088/api/v1/security/csrf_token/")
      .with(
        headers: {
          Authorization: "Bearer fake_token"
        }
      )
      .to_return(
        status:  200,
        body:    { result: "fake_csrf_token" }.to_json,
        headers: { "Content-Type": "application/json" }
      )

    stub_request(:post, "http://superset:8088/api/v1/security/users/")
      .with(
        headers: {
          Authorization:  "Bearer fake_token",
          "X-CSRFToken":  "fake_csrf_token",
          "Content-Type": "application/json"
        },
        body:    hash_including(
          first_name: "fhirboard",
          last_name:  "user",
          active:     true,
          roles:      [1]
        )
      )
      .to_return(
        status:  200,
        body:    { id: 1 }.to_json,
        headers: { "Content-Type": "application/json" }
      )

    stub_request(:post, "http://superset:8088/api/v1/database/")
      .with(
        headers: {
          Authorization:  "Bearer fake_token",
          "X-CSRFToken":  "fake_csrf_token",
          "Content-Type": "application/json"
        }
      )
      .to_return(
        status:  200,
        body:    { id: 123 }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    allow_any_instance_of(Utils::Services::InitializeDuckdbDatabase)
      .to receive(:call)
      .and_return(true)
  end

  it "creates a session" do
    expect { call }.to change(Session, :count).by(1)
  end

  describe "duckdb database creation" do
    let(:duckdb_service) { instance_double(Utils::Services::InitializeDuckdbDatabase) }

    before do
      allow(Utils::Services::InitializeDuckdbDatabase).to receive(:new).and_return(duckdb_service)
      allow(duckdb_service).to receive(:call)
    end

    it "initializes the duckdb database" do
      call
      expect(duckdb_service).to have_received(:call)
    end
  end

  describe "analysis duplication" do
    let!(:sample_analysis)     { create(:analysis, sample: true, name: "Analysis 1") }
    let!(:non_sample_analysis) { create(:analysis, sample: false, name: "Analysis 2") }

    let!(:view_definition_11) { create(:view_definition, analysis: sample_analysis) }
    let!(:view_definition_12) { create(:view_definition, analysis: sample_analysis) }

    it "duplicates the sample analyses" do
      session = call

      expect(session.analyses.pluck(:name)).to include(sample_analysis.name)
    end

    it "does not duplicate the non-sample analyses" do
      session = call

      expect(session.analyses.pluck(:name)).not_to include(non_sample_analysis.name)
    end

    it "duplicates the view definitions" do
      session = call

      analysis = session.analyses.where(name: sample_analysis.name).first
      expect(analysis.view_definitions.count).to eq(2)
    end

    it "assigns the session to the duplicated analyses" do
      session = call

      analysis = session.analyses.where(name: sample_analysis.name).first
      expect(analysis.view_definitions.pluck(:session_id).uniq).to eq([session.id])
    end
  end

  describe "superset integration" do
    let(:api_service) { instance_double(Superset::Services::ApiService) }
    let(:api_response) { double(success?: true, body: { "id" => 123 }) }

    before do
      allow(Superset::Services::ApiService).to receive(:new).and_return(api_service)
      allow(api_service).to receive(:create_user)
      allow(api_service).to receive(:create_database_connection).and_return(api_response)
    end

    it "creates a superset user" do
      call
      expect(api_service).to have_received(:create_user)
    end

    it "creates a database connection" do
      call
      expect(api_service).to have_received(:create_database_connection)
    end

    it "saves the database connection id to the session" do
      session = call
      expect(session.superset_db_connection_id).to eq(123)
    end

    context "when database connection creation fails" do
      let(:api_response) { double(success?: false, body: { "error" => "Failed" }) }

      it "raises an error" do
        expect { call }.to raise_error(/Failed to create Superset database/)
      end
    end
  end
end
