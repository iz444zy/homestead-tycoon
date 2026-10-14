"""Deterministic autumn art pass; no gameplay scripts or uploaded assets."""
import math
import random


def enrich_world(plot, workspace, part, item, folder):
    rng = random.Random(713)
    # Built-in Roblox material IDs keep this place portable and self-contained.
    GRASS, WOOD, PLANKS, SLATE, STONE, FABRIC, BRICK = 1280, 512, 528, 800, 880, 1312, 848

    def set_prop(node, name, value):
        prop = node.find(f"Properties/*[@name='{name}']")
        if prop is not None:
            prop.text = str(value).lower() if isinstance(value, bool) else str(value)

    def tint(node, rgb):
        for channel, value in zip(node.find("Properties/Color3[@name='Color']"), rgb):
            channel.text = str(value / 255)

    # Existing collision and interaction geometry stays intact.
    for node in plot.iter("Item"):
        props = node.find('Properties')
        if props.find("token[@name='Material']") is None:
            continue
        name = props.find("string[@name='Name']").text
        if name in ('FlatProperty', 'SurroundingGround', 'ReservedFootprint'):
            set_prop(node, 'Material', GRASS)
        elif any(word in name for word in ('Roof', 'Ridge')):
            set_prop(node, 'Material', SLATE)
        elif any(word in name for word in ('Foundation', 'Chimney', 'GateCap')):
            set_prop(node, 'Material', BRICK if name == 'Chimney' else STONE)
        elif 'Wall' in name or name == 'DoorHeader':
            set_prop(node, 'Material', 816)  # softly textured plaster/concrete
            tint(node, (221, 198, 155))
        elif any(word in name for word in ('Post', 'Rail', 'Beam', 'Frame', 'Jamb', 'Lintel', 'Sill', 'Brace', 'Gable', 'Border', 'Stake', 'Sign')):
            set_prop(node, 'Material', WOOD)
        elif name in ('Floor', 'PorchDeck', 'Step', 'OpenDoor'):
            set_prop(node, 'Material', PLANKS)
        elif name == 'Window':
            tint(node, (224, 172, 95))
        elif name == 'DoorstepMat':
            set_prop(node, 'Material', FABRIC)
            tint(node, (90, 111, 83))

    art = folder('AutumnDetails', plot)

    def decor(name, parent, size, pos, color, material=272, **kwargs):
        node = part(name, parent, size, pos, color, collide=False,
                    CanQuery=('bool', False), **kwargs)
        set_prop(node, 'Material', material)
        return node

    # Broad horizontal siding courses and shutters bring the cottage closer to home.
    house = folder('CottageFinish', art)
    for x in (-81, -59):
        for dx in (-3.55, 3.55):
            decor('SageShutter', house, (1.35, 4.8, .42), (x+dx, 7.1, -50.55), (77, 103, 77), PLANKS)
        decor('WindowBox', house, (6.2, 1, 1.6), (x, 4.25, -49.9), (124, 84, 54), WOOD)
        for j in range(3):
            decor('GoldenMums', house, (1.5, .85, 1.35), (x-1.8+j*1.8, 5, -49.7), (188+j*12, 117+j*13, 45), Shape=('token', 0))
    for y in (3, 5, 7, 9, 11):
        for x in (-81, -59):
            decor('SidingCourse', house, (11.7, .10, .12), (x, y, -50.92), (188, 159, 116), WOOD)
        for x in (-87.03, -52.97):
            decor('SideSidingCourse', house, (.12, .10, 27.8), (x, y, -65), (188, 159, 116), WOOD)
    # Lanterns are beside the door; the full doorway and stair width remain open.
    for x in (-76, -64):
        decor('LanternBracket', house, (.35, 1.5, .9), (x, 9, -50.1), (66, 61, 49))
        lamp = decor('AmberLantern', house, (.75, 1.1, .75), (x, 8.5, -49.6), (247, 198, 114))
        for y in (7.88, 9.12):
            decor('LanternFrame', house, (1, .18, 1), (x, y, -49.6), (69, 63, 48))
        item('PointLight', 'PorchLight', lamp, Color=('Color3', (255, 204, 135)), Brightness=('float', .65), Range=('float', 11), Shadows=('bool', False))

    # A connected lane outside the lot, plus side/back passages for future expansion.
    lanes = folder('VillageConnections', art)
    for size, pos in [((760, .14, 16), (0, .075, 135)),
                      ((12, .14, 25), (-17, .075, 122)),
                      ((140, .14, 12), (175, .075, 3)),
                      ((140, .14, 12), (-175, .075, 3)),
                      ((12, .14, 90), (-17, .075, -138))]:
        decor('OpenVillageLane', lanes, size, pos, (183, 169, 132), 1296)

    def crown(parent, x, y, z, radius, height, color):
        # Eight broad triangular faces form a low-poly canopy instead of a sphere.
        for lower in (False, True):
            for i in range(4):
                a = i * math.pi / 2
                dx = (math.cos(a) + math.sin(a)) * radius / 2
                dz = (-math.sin(a) + math.cos(a)) * radius / 2
                angle = a + math.pi / 2
                pos = (x+dx, y + (-1 if lower else 1)*height/4, z + (-dz if lower else dz))
                shade = tuple(max(0, min(255, c + (i % 3 - 1)*7)) for c in color)
                node = decor('CanopyFacet', parent, (radius, height/2, radius), pos, shade, angle=angle, cls='CornerWedgePart')
                if lower:
                    co, si = math.cos(angle), math.sin(angle)
                    frame = [*pos, co, 0, si, 0, -1, 0, si, 0, -co]
                    for e, v in zip(node.find('Properties/CoordinateFrame'), frame):
                        e.text = str(v)

    palette = [(172, 91, 43), (199, 135, 51), (151, 66, 43), (178, 151, 65), (79, 105, 58)]

    def tree(parent, x, z, scale, index):
        model = item('Model', f'AutumnTree{index:02}', parent)
        h = 19*scale
        decor('Trunk', model, (2*scale, h, 2*scale), (x, h/2, z), (98, 72, 49), WOOD, angle=.06, axis='z')
        for sign in (-1, 1):
            decor('Branch', model, (1.1*scale, 9*scale, 1.1*scale), (x+sign*2.6*scale, h*.8, z), (111, 78, 48), WOOD, angle=-sign*.6, axis='z')
        col = palette[index % len(palette)]
        for dx, dz, dy, r in [(0, 0, 7, 8), (-5, 1, 2, 6.4), (4, -2, 3, 6.8)]:
            crown(model, x+dx*scale, h+dy*scale, z+dz*scale, r*scale, r*1.85*scale, col)

    forest = folder('AutumnForest', art)
    positions = []
    # Broken groves, never a continuous fence. Road corridors remain clear.
    for z in (-190, -270, -345):
        for x in range(-370, 391, 56):
            if abs(x+17) < 30:
                continue
            positions.append((x+rng.uniform(-15, 15), z+rng.uniform(-13, 13)))
    for sign in (-1, 1):
        for z in (-110, -55, 60, 195, 260):
            positions.append((sign*rng.uniform(180, 240), z))
    # A few trees frame the homestead outside its reservation/lawn footprint.
    positions += [(-128, -69), (129, -76), (-133, 76), (137, 77)]
    for i, (x, z) in enumerate(positions):
        tree(forest, x, z, rng.uniform(.8, 1.35), i)

    # Mountain groups stand beyond the groves, with open east/west/south horizons.
    mountains = folder('DistantMountains', art)
    for i, (x, z, width, height) in enumerate([
        (-620, -630, 290, 185), (-390, -720, 320, 240), (-110, -790, 340, 260),
        (170, -770, 310, 210), (430, -690, 330, 245), (650, -560, 260, 160),
        (-470, -505, 240, 130), (-200, -540, 260, 155), (100, -565, 250, 125), (370, -485, 260, 145)]):
        model = item('Model', f'Ridge{i:02}', mountains)
        # Keep the skyline low and distant: scenery, never an enclosing wall.
        height *= .56
        z -= 160
        col = (133, 153, 165) if i < 6 else (112, 138, 127)
        # Four wedges create a broad faceted pyramid; all scenery is nonblocking.
        for j in range(4):
            a = j*math.pi/2
            dx = (math.cos(a)+math.sin(a))*width/4
            dz = (-math.sin(a)+math.cos(a))*width/4
            decor('MountainFace', model, (width/2, height, width/2), (x+dx, height/2-3, z+dz), tuple(c+(j%2)*9 for c in col), angle=a+math.pi/2, cls='CornerWedgePart')

    # Small dimensional grass tufts only in margins: no clutter in the meadow,
    # paths, entrance corridors, or the reserved growing areas.
    meadow = folder('MeadowMargins', art)
    for i in range(65):
        clump = folder(f'Tuft{i:02}', meadow)
        x = rng.choice((-1, 1))*rng.uniform(96, 103)
        z = rng.uniform(-86, 86)
        if -16 < z < 22:
            continue
        for j in range(3):
            decor('GrassBlade', clump, (.18, rng.uniform(.6, 1.25), .65), (x+j*.3, .45, z), (80+j*6, 119+j*5, 54), angle=(j-1)*.25, axis='z', cls='WedgePart')
    # Low leaf drifts echo forest colors near the boundary, away from all prompts.
    leaves = folder('FallLeafDrifts', art)
    for i, (cx, cz) in enumerate([(-100, 82), (101, 82), (-99, -84), (100, -85)]):
        for j in range(9):
            decor('LeafCluster', leaves, (rng.uniform(.8, 1.8), .08, rng.uniform(.5, 1.2)), (cx+rng.uniform(-4, 4), .1, cz+rng.uniform(-3, 3)), palette[(i+j)%4], angle=rng.uniform(0, math.pi))
