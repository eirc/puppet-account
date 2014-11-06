# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'rake', :task => 'lint' do
  watch(%r{^manifests/.*\.pp})
end

guard 'rake', :task => 'syntax' do
  watch(%r{^manifests/.*\.pp})
end

guard 'rake', :task => 'spec' do
  watch(%r{^manifests/.*\.pp})
  watch(%r{^spec/(classes|defines|unit|functions|hosts|integration)/.*_spec\.rb})
end
