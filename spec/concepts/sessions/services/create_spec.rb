# frozen_string_literal: true

describe Sessions::Services::Create do
  subject(:call) { described_class.new.call }

  let(:superset_database_id) { 1 }

  before do
    allow_any_instance_of(Superset::Services::CreateAccount)
      .to receive(:call)
      .and_return(superset_database_id)

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

  describe "superset account creation" do
    let(:superset_account_service) { instance_double(Superset::Services::CreateAccount) }

    before do
      allow(Superset::Services::CreateAccount).to receive(:new).and_return(superset_account_service)
      allow(superset_account_service).to receive(:call).and_return(superset_database_id)
    end

    it "creates superset account" do
      call
      expect(superset_account_service).to have_received(:call)
    end

    it "saves superset db id in session" do
      session = call
      expect(session.superset_db_connection_id).to eq(superset_database_id)
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
end
