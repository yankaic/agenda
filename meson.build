project('com.github.dahenson.agenda', ['vala', 'c'],
    version: '1.1.2'
)

# dependencies
glib    = dependency('glib-2.0')
gio     = dependency('gio-2.0')
gobject = dependency('gobject-2.0')
gtk     = dependency('gtk+-3.0')
granite = dependency('granite')
gee     = dependency('gee-0.8')
sqlite  =    dependency('sqlite3')

gnome = import('gnome')
i18n = import('i18n')

asresources = gnome.compile_resources(
    'as-resources', 'data/css.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

add_project_arguments(
    ['--vapidir', join_paths(meson.current_source_dir(), 'vapi')],
    language: 'vala'
)

conf = configuration_data()
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('PKGDATADIR', join_paths(get_option('datadir'), meson.project_name()))
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

vala_args = [
    '--pkg', 'config'
]

c_args = [
    '-include', 'config.h'
]

subdir('lib')
subdir('test')

agenda_client_sources = files(
    'src/Agenda.vala',
    'src/Window.vala',
    'src/Widgets/TaskView.vala',
    'src/Backend/BackendInterface.vala',
    'src/Backend/SqliteBackend.vala',
    'src/Models/HistoryList.vala',
    'src/Models/TaskListHistory.vala',
    'src/Models/TaskList.vala',
    'src/Models/Task.vala',
    'src/Models/Stack.vala',
)

agenda_deps = [
    glib,
    gtk,
    granite,
    sqlite
]

executable(
    meson.project_name(),
    agenda_client_sources,
    asresources,
    vala_args: vala_args,
    c_args: c_args,
    dependencies: agenda_deps,
    install : true,
)

meson.add_install_script('meson/post_install.py')

subdir('data')
subdir('po')
