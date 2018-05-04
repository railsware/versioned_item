require 'spec_helper'

module VersionedItem
  RSpec.describe Extension do
    subject { Dummy[version] }
    let(:version) { 1 }

    before do
      stub_const('Dummy', Class.new { extend Extension })
    end

    context 'no available versions set' do
      it 'raises VersionsNotConfigured' do
        expect { subject }.to raise_error VersionsNotConfigured
      end
    end

    context 'available versions set' do
      before { VersionedItem.available_versions = available_versions }

      context 'requested version is not available' do
        let(:available_versions) { [1] }
        let(:version) { 2 }

        it 'raises VersionNotFound' do
          expect { subject }.to raise_error VersionNotFound
        end
      end

      context 'usual flow' do
        let(:available_versions) { [1, 2.1, 3] }

        before do
          stub_const('V1::Dummy', Class.new { def self.call; 'v1'; end })
          stub_const('V2_1::Dummy', Class.new { def self.call; 'v2'; end })
        end

        shared_examples :it_works do |expected|
          it 'uses correct class' do
            expect(subject.call).to eq expected
          end
        end

        context 'version of class exists' do
          context 'version passed as int' do
            let(:version) { 1 }

            it_behaves_like :it_works, 'v1'
          end

          context 'version passed as string' do
            let(:version) { '1' }

            it_behaves_like :it_works, 'v1'
          end

          context 'version passed as float' do
            let(:version) { 2.1 }

            it_behaves_like :it_works, 'v2'
          end
        end

        context 'falback version of class exists' do
          let(:version) { 3 }

          it 'uses fallback class' do
            expect(subject.call).to eq 'v2'
          end
        end

        context 'falback version of class does not exist' do
          subject { Dummy2[version] }
          let(:version) { 3 }

          before do
            stub_const('Dummy2', Class.new { extend Extension })
          end

          it 'raises ItemNotFound' do
            expect { subject }.to raise_error ItemNotFound
          end
        end
      end
    end
  end
end
