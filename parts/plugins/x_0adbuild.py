import os.path
import snapcraft


class X0ADBuildPlugin(snapcraft.BasePlugin):

    def build(self):
        patches_dir = os.path.join(self.project.parts_dir, 'patches')
        patches = ['allow-build-with-root.patch']
        for patch in patches:
            with open(os.path.join(patches_dir, patch), 'rb', 0) as pfile:
                self.run(['patch', '-d', self.builddir, '-p1'], stdin=pfile)
        parallel_arg = '-j{}'.format(self.parallel_build_count)
        self.run(['build/workspaces/update-workspaces.sh',
                  '--with-system-nvtt',
                  parallel_arg])
        self.run(['make', parallel_arg, 'config=release',
                  '-C', 'build/workspaces/gcc'])
        snapcraft.file_utils.link_or_copy_tree(
            os.path.join(self.builddir, 'binaries'),
            os.path.join(self.installdir, 'binaries'))
