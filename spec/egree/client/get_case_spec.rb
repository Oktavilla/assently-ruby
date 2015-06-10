require "luhn"
require "spec_helper"

require "egree/client"
require "egree/case"
require "egree/document"
require "egree/party"

module Egree
  describe Egree::Client do
    let :client do
      Egree::Client.new ENV["EGREE_API_KEY"], ENV["EGREE_API_SECRET"], :test
    end

    describe "#get_case" do
      describe "with a reference_id as argument" do
        it "sends the getcase query with the case reference id json" do
          allow(client).to receive :post

          reference_id = Egree::Case.generate_reference_id
          serialized_json = "{\n  \"id\": \"#{reference_id}\"\n}"

          expect(Egree::Serializers::ReferenceIdSerializer).to receive(:serialize).with(reference_id.to_s).and_return "reference_id"

          client.get_case reference_id

          expect(client).to have_received(:post).with "/api/v2/getcase", serialized_json
        end
      end

      describe "with a case as argument" do
        it "sends the getviewcaseurl query with the case reference id json" do
          allow(client).to receive :post

          reference_id = double "Egree::ReferenceId"
          signature_case = double "Egree::Case", reference_id: reference_id
          serialized_json = "{\n  \"id\": \"#{reference_id}\"\n}"

          expect(Egree::Serializers::ReferenceIdSerializer).to receive(:serialize).with(reference_id).and_return "reference-id"

          client.get_case signature_case

          expect(client).to have_received(:post).with "/api/v2/getcase", serialized_json
        end
      end

      describe "when the case exists", vcr: { cassette_name: "Egree_Client/_get_case/case_exists" } do
        let :reference_id do
          Egree::Case.generate_reference_id
        end

        before do
          create_case reference_id
        end

        describe "result" do
          it "is successfull" do
            result = client.get_case reference_id

            expect(result.success?).to be true
          end

          it "has the url as the response" do
            result = client.get_case reference_id

            expect(result.response).to match "https://test.egree.com"
          end
        end
      end

      describe "when there is no matching case" do
        describe "result", vcr: { cassette_name: "Egree_Client/_get_case/case_missing" } do
          it "is not successfull" do
            result = client.get_case "missing-case"

            expect(result.success?).to be false
          end

          it "has the error" do
            result = client.get_case "missing-case"

            expect(result.errors[0]).to eq "E030 User is not creator of case."
          end
        end
      end
    end

    private

    def create_case reference_id = nil
      signature_case = Egree::Case.new "Agreement", ["touch"], case_id: reference_id
      signature_case.add_party Egree::Party.new_with_attributes({
        name: "First Last",
        email: "name@example.com",
        social_security_number: Luhn::CivicNumber.generate
      })
      signature_case.add_document Egree::Document.new(File.join(Dir.pwd, "spec/fixtures/agreement.pdf"))

      signature_case.reference_id = reference_id if reference_id

      client.create_case signature_case
    end
  end
end

