# encoding: utf-8
$stdout.set_encoding('UTF-8')
$stderr.set_encoding('UTF-8')
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'xcodeproj'

PROJECT_PATH = 'BuzzPlay.xcodeproj'
TEST_TARGET_NAME = 'BuzzPlayTests'
MAIN_TARGET_NAME = 'BuzzPlay'
BUNDLE_ID = 'com.RomainPoyard.BuzzPlayTests'
SWIFT_VERSION = '5.9'

project = Xcodeproj::Project.open(PROJECT_PATH)
main_target = project.targets.find { |t| t.name == MAIN_TARGET_NAME }

# Ne pas créer si déjà existant
if project.targets.any? { |t| t.name == TEST_TARGET_NAME }
  puts "Target '#{TEST_TARGET_NAME}' already exists, skipping."
  exit 0
end

# ── 1. Créer le test target ───────────────────────────────────────────────────
test_target = project.new_target(
  :unit_test_bundle,
  TEST_TARGET_NAME,
  :ios,
  '17.0'
)

# ── 2. Lier au main target ────────────────────────────────────────────────────
test_target.add_dependency(main_target)

# ── 3. Build settings ─────────────────────────────────────────────────────────
['Debug', 'Release'].each do |config_name|
  config = test_target.build_configurations.find { |c| c.name == config_name }
  next unless config
  config.build_settings.merge!(
    'BUNDLE_LOADER'                 => '$(TEST_HOST)',
    'TEST_HOST'                     => '$(BUILT_PRODUCTS_DIR)/BuzzPlay.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/BuzzPlay',
    'PRODUCT_BUNDLE_IDENTIFIER'     => BUNDLE_ID,
    'SWIFT_VERSION'                 => SWIFT_VERSION,
    'IPHONEOS_DEPLOYMENT_TARGET'    => '17.0',
    'ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES' => 'YES',
    'CODE_SIGN_STYLE'               => 'Automatic',
    'DEVELOPMENT_TEAM'              => main_target.build_configurations.first.build_settings['DEVELOPMENT_TEAM'] || '',
    'ENABLE_TESTING_SEARCH_PATHS'   => 'YES',
  )
end

# ── 4. Groupe de fichiers dans le navigateur ──────────────────────────────────
tests_group = project.main_group.new_group(TEST_TARGET_NAME, TEST_TARGET_NAME)

sub_groups = {
  'Mocks'      => 'BuzzPlayTests/Mocks',
  'Fixtures'   => 'BuzzPlayTests/Fixtures',
  'ViewModels' => 'BuzzPlayTests/ViewModels',
}

# Fichier racine
root_file_path = 'BuzzPlayTests/BuzzPlayTests.swift'
root_ref = tests_group.new_file(root_file_path)
test_target.add_file_references([root_ref])

# Sous-dossiers
sub_groups.each do |group_name, dir|
  group = tests_group.new_group(group_name, group_name)
  Dir.glob("#{dir}/*.swift").each do |file_path|
    ref = group.new_file(file_path)
    test_target.add_file_references([ref])
  end
end

# ── 5. Sauvegarder ───────────────────────────────────────────────────────────
project.save
puts "✅ Target '#{TEST_TARGET_NAME}' created and saved to #{PROJECT_PATH}"
