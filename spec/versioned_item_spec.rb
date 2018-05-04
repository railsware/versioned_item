RSpec.describe VersionedItem do
  describe '.available_versions=' do
    context 'type castes arguments to strings' do
      subject { described_class.available_versions }
      
      before { described_class.available_versions = [1, 2.1, '3']  }

      it { is_expected.to eq ['1', '2.1', '3'] }
    end
  end
end
