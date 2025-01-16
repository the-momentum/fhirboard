# frozen_string_literal: true

describe Sessions::Services::Create do
  subject(:call) { described_class.new.call }

  it 'creates a session' do
    expect { call }.to change(Session, :count).by(1)
  end

  context "with sample analyses" do
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
