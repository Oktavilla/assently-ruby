require "spec_helper"

require "egree/case"
require "egree/api_mappers/case_mapper"

module Egree
  module ApiMappers
    RSpec.describe CaseMapper do
      describe "#to_api" do
        it "maps the case into an has that complies with the expected format" do
          party = double "Party"
          document = double "Document"

          case_id = SecureRandom.uuid

          signature_case = Egree::Case.new "Agreement", ["electronicid"], case_id: case_id
          signature_case.add_party party
          signature_case.add_document document

          expect(Egree::ApiMappers::PartyMapper).to receive(:to_api).with(party).and_return(party: "on")
          expect(Egree::ApiMappers::DocumentMapper).to receive(:to_api).with(document).and_return(document: "on")

          api_hash = CaseMapper.to_api signature_case

          expect(api_hash).to eq({
            "Id" => case_id,
            "CaseReferenceId" => signature_case.reference_id.to_s,
            "Name" => "Agreement",
            "NameAlias" => "Agreement_alias",
            "Documents" => [{ document: "on" }],
            "Parties" => [{ party: "on" }],
            "AllowedSignatureTypes" => ["electronicid"]
          })
        end
      end
    end
  end
end
