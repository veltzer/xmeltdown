'''
dependencies for this project
'''

def populate(d):
    # ubuntu packages for development
    d.packs_dev=[
        #for makedepend(1)
        'xutils-dev',
        #for the X11 API
        'libx11-dev',
    ]

def getdeps():
    return [
        __file__, # myself
    ]
