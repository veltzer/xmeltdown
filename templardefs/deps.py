'''
dependencies for this project
'''

def populate(d):
    d.packs=[
        #for makedepend(1)
        'xutils-dev',
        #for the X11 API
        'libx11-dev',
    ]

def getdeps():
    return [
        __file__, # myself
    ]
