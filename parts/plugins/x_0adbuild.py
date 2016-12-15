import os.path
import snapcraft


class X0ADBuildPlugin(snapcraft.BasePlugin):

    def build(self):
        parallel_arg = '-j{}'.format(self.parallel_build_count)
        self.run(['build/workspaces/update-workspaces.sh',
                  '--with-system-nvtt',
                  parallel_arg])
        self.run(['make', parallel_arg, 'config=release',
                  '-C', 'build/workspaces/gcc'])
        snapcraft.file_utils.link_or_copy_tree(
            os.path.join(self.builddir, 'binaries'),
            os.path.join(self.installdir, 'binaries'))
