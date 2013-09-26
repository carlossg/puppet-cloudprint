require 'spec_helper'

describe 'cloudprint' do

  let(:params) {{
    :username  => 'johndoe@gmail.com',
    :password  => 'mypassword',
    :connector => 'my_printer'
  }}

  it { should contain_service('cloudprintproxy').with_ensure('running') }
  it { should contain_exec('/etc/cloudprint/generate_cloudprint_config.py johndoe@gmail.com mypassword my_printer http://localhost:631') }

end
