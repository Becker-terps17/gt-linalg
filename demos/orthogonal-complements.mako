## /* -*- javascript -*-

<%! draggable=True %>
<%! clip_shader=True %>

<%inherit file="base.mako"/>

<%block name="title">Span of three vectors</%block>

<%block name="inline_style">
  #span-type, #complement-type {
      border: solid 1px white;
      padding: 2px;
  }

  .dg.main .cr.boolean > div > .property-name {
      width: 60%;
  }
  .dg.main .cr.boolean > div > .c {
      width: 40%;
  }
</%block>

## */

var paramsQS = Demo.prototype.decodeQS();
var range = [[-10,10],[-10,10],[-10,10]];
if(paramsQS.range) {
    range = parseFloat(paramsQS.range);
    range = [[-range, range], [-range, range], [-range, range]];
}
var camera = [-1.5, 1.5, -3];
if(paramsQS.camera) {
    camera = paramsQS.camera.split(",").map(parseFloat);
}

new Demo({
    mathbox: {
        plugins: ['core', 'controls'],
        controls: {
            klass: THREE.OrbitControls,
            parameters: {
                // noZoom: true,
            }
        },
        mathbox: {
            warmup: 10,
            splash: true,
            inspect: false,
        },
        splash: {fancy: true, color: "blue"},
    },
    camera: {
        proxy:     true,
        position: camera,
        lookAt:   [0, 0, 0],
        up:       [0, 1, 0]
    },
    grid: false,
    caption: '&nbsp;',
    viewRange: range,

}, function() {
    var self = this;

    mathbox.select(".axes").set('zIndex', 1);

    var vector1, vector2, vector3;
    if(paramsQS.v3) {
        vector1 = paramsQS.v1.split(",").map(parseFloat);
        vector2 = paramsQS.v2.split(",").map(parseFloat);
        vector3 = paramsQS.v3.split(",").map(parseFloat);
    } else {
        vector1 = [5, 3, -2];
        vector2 = [3, -4, 1];
        vector3 = [-1, 1, 7];
    }
    var vectors = [vector1, vector2, vector3];

    var ortho1 = new THREE.Vector3(vector1[0],vector1[1],vector1[2]);
    var ortho2 = new THREE.Vector3(vector2[0],vector2[1],vector2[2]);
    var ortho = [ortho1, ortho2];
    this.orthogonalize(ortho1, ortho2);
    var color1 = [1, .3, 1, 1];
    var color2 = [0, 1, 0, 1];
    var color3 = [1, 1, 0, 1];
    var colors = [color1, color2, color3];
    var tColor1 = new THREE.Color(color1[0], color1[1], color1[2]);
    var tColor2 = new THREE.Color(color2[0], color2[1], color2[2]);
    var tColor3 = new THREE.Color(color3[0], color3[1], color3[2]);

    var normal1 = new THREE.Vector3();
    var normal2 = new THREE.Vector3();


    this.labeledVectors(vectors, colors, ['v1', 'v2', 'v3'], {
        zeroPoints: true,
    });
    mathbox.select("#vectors-drawn").set('zIndex', 2);
    mathbox.select("#vector-labels").set('zIndex', 2);
    mathbox.select("#zero-points").set('zIndex', 3);

    // Spanning surface stuff
    var surfaceColor = new THREE.Color(0.5, 0, 0);
    var surfaceOpacity = 0.5;

    var complementColor = new THREE.Color(0, 0.7, 0.7);
    var complementOpacity = 0.5;

    var originSize = 30;
    var originOpacity = 1;

    var clipped = this.clipCube({
        drawCube: true,
        wireframeColor: new THREE.Color(.75, .75, .75),
        material: new THREE.MeshBasicMaterial({
            color:       surfaceColor,
            opacity:     0.5,
            transparent: true,
            visible:     true,
            depthWrite:  false,
            depthTest:   true,
        }),
    });

    three.scene.add(self.clipCubeMesh);
    // The cube texture is the "space" span.  Make sure it's visible from
    // inside the cube.
    three.on('pre', function () {
        if(Math.abs(self.camera.position.x) < 1.0 &&
           Math.abs(self.camera.position.y) < 1.0 &&
           Math.abs(self.camera.position.z) < 1.0)
            self.clipCubeMesh.material.side = THREE.BackSide;
        else
            self.clipCubeMesh.material.side = THREE.FrontSide;
    });

    // Spanned surface
    clipped
        .matrix({
            channels: 3,
            live:     true,
            width:    2,
            height:   2,
            expr: function (emit, i, j) {
                if(i == 0) i = -1;
                if(j == 0) j = -1;
                i *= 30; j *= 30;
                emit(ortho1.x * i + ortho2.x * j,
                     ortho1.y * i + ortho2.y * j,
                     ortho1.z * i + ortho2.z * j);
            }
        })
    ;
    var surface = clipped
        .surface({
            color:   surfaceColor,
            opacity: surfaceOpacity,
            stroke:  "solid",
            lineX:   true,
            lineY:   true,
            width:   5,
            visible: false,
        })
    ;


    // orthogonal complement
    clipped
	.matrix({
            channels: 3,
            live:     true,
            width:    2,
            height:   2,
            expr: function (emit, i, j) {
                if(i == 0) i = -1;
                if(j == 0) j = -1;
                i *= 300; j *= 300;
                emit(normal1.x * i + normal2.x * j,
                     normal1.y * i + normal2.y * j,
                     normal1.z * i + normal2.z * j);
            }
	})
    ;
    var ortho_complement = clipped
        .surface({
            color:   complementColor,
            opacity: complementOpacity,
            stroke:  "solid",
            lineX:   true,
            lineY:   true,
            width:   5,
            visible: false,
        })
    ;


    clipped
        .matrix({
            channels: 3,
            live:     true,
            width:    2,
            height:   2,
            expr: function (emit, i, j) {
                if(i == 0) i = -1;
                if(j == 0) j = -1;
                i *= 30; j *= 30;
                emit(ortho1.x * i + ortho2.x * j,
                     ortho1.y * i + ortho2.y * j,
                     ortho1.z * i + ortho2.z * j);
            }
        })
    ;
    var surface = clipped
        .surface({
            color:   surfaceColor,
            opacity: surfaceOpacity,
            stroke:  "solid",
            lineX:   true,
            lineY:   true,
            width:   5,
            visible: false
        })
    ;

    // Origin
    clipped
        .array({
            channels: 3,
            width:    1,
	    data: [0, 0, 0]
        })
    var origin = clipped
	.point({
	    size: originSize,
	    color: complementColor,
	    opacity: originOpacity,
	    visible: true,
	    zIndex: 10
	})
    ;



    var snap_threshold = 1.0;
    var zero_threshold = 0.00001;
    var spanType;
    var complementType;

    function updateSpan(spanDim) {
        switch(spanDim) {
        case 0:
            if(paramsQS.indep)
                spanType.innerText = "linearly dependent";
            else {
                spanType.innerText = "a point";
		complementType.innerText = "space";
	    }
            surface.set('visible', false);
	    ortho_complement.set('visible', false);
	    origin.set({visible: true, color: surfaceColor});
            self.clipCubeMesh.material.visible = true;
	    self.clipCubeMesh.material.color = complementColor;
            break;
        case 1:
            if(paramsQS.indep)
                spanType.innerText = "linearly dependent";
            else {
                spanType.innerText = "a line";
	    	complementType.innerText = "a plane";
	    }
            surface.set({visible: true, opacity: 1.0});
	    ortho_complement.set('visible', true);
	    origin.set({visible: false});
            self.clipCubeMesh.material.visible = false;
            break;
        case 2:
            if(paramsQS.indep)
                spanType.innerText = "linearly dependent";
            else {
                spanType.innerText = "a plane";
	    	complementType.innerText = "a line";
	    }
            surface.set({visible: true, opacity: 0.5});
	    ortho_complement.set('visible', true);
	    origin.set({visible: false});
            self.clipCubeMesh.material.visible = false;
            break;
        case 3:
            if(paramsQS.indep)
                spanType.innerText = "linearly independent";
            else {
                spanType.innerText = "space";
	    	complementType.innerText = "a point";
	    }
            surface.set('visible', false);
	    ortho_complement.set('visible', false);
	    origin.set({visible: true, color: complementColor});
            self.clipCubeMesh.material.visible = true;
	    self.clipCubeMesh.material.color = surfaceColor;
            break;
        }
    }

    function normal_plane_basis(vec) {
	var vecz = new THREE.Vector3(vec.y,-vec.x,0);
	var vecy = new THREE.Vector3(vec.z,0,-vec.x);
	var vecx = new THREE.Vector3(0, vec.z, -vec.y);
	var vec1, vec2;
	if (vec.x != 0){
	    var vec1 = vecy;
	    var vec2 = vecz;
	} else if (vec.y != 0) {
	    var vec1 = vecx;
	    var vec2 = vecz;
	} else if (vec.z != 0) {
	    var vec1 = vecy;
	    var vec2 = vecx;
	}
	Demo.prototype.orthogonalize(vec1, vec2);
	return [vec1, vec2];
    }

    function normal_line(vec1, vec2) {
	var temp = new THREE.Vector3();
	temp.crossVectors(vec1, vec2);
	return temp;
    }

    var onDrag = (function() {
        var otherVec1 = new THREE.Vector3();
        var otherVec2 = new THREE.Vector3();
        var projection = new THREE.Vector3();
        var diff = new THREE.Vector3();

        return function(vec) {
            var indices = [0,1,2].filter(
                function(x) { return x!=draggable.dragging });
            var other1 = vectors[indices[0]];
            var other2 = vectors[indices[1]];
            otherVec1.set.apply(otherVec1, other1);
            otherVec2.set.apply(otherVec2, other2);
	    var cross = new THREE.Vector3();
            cross.crossVectors(otherVec1, otherVec2);
            var vec1Zero = (otherVec1.x == 0.0 &&
                            otherVec1.y == 0.0 &&
                            otherVec1.z == 0.0);
            var vec2Zero = (otherVec2.x == 0.0 &&
                            otherVec2.y == 0.0 &&
                            otherVec2.z == 0.0);
            var vecZero = false;
            var linIndep = !(Math.abs(cross.x) < zero_threshold &&
                             Math.abs(cross.y) < zero_threshold &&
                             Math.abs(cross.z) < zero_threshold);
            var spanDim;

            // snap to zero
            if(vec.dot(vec) < snap_threshold) {
                vec.set(0, 0, 0);
                vecZero = true;
                if(vec1Zero && vec2Zero) {
                    ortho1.set(0, 0, 0);
                    ortho2.set(0, 0, 0);
                    spanDim = 0;
                }
                else if(vec1Zero) {
                    ortho1.set(0, 0, 0);
                    ortho2.copy(otherVec2).normalize();
                    spanDim = 1;
		    [normal1, normal2] = normal_plane_basis(ortho2);
                }
                else if(vec2Zero || !linIndep) {
                    ortho1.copy(otherVec1).normalize();
                    ortho2.set(0, 0, 0);
                    spanDim = 1;
		    [normal1, normal2] = normal_plane_basis(ortho1);
                }
                else {
                    self.orthogonalize(
                        ortho1.copy(otherVec1), ortho2.copy(otherVec2));
                    spanDim = 2;
                }
            }
            else if(vec1Zero && vec2Zero) {
                ortho1.copy(vec).normalize();
                ortho2.set(0, 0, 0);
                spanDim = 1;
		[normal1, normal2] = normal_plane_basis(ortho1);
            }
            else if(vec1Zero) {
                // otherVec2 is nonzero
                projection.copy(vec).projectOnVector(otherVec2);
                diff.copy(projection).sub(vec);
                if(diff.dot(diff) < snap_threshold) {
                    // Snap to OtherVec2
                    vec.copy(projection);
                    ortho1.set(0, 0, 0);
                    ortho2.copy(otherVec2).normalize();
                    spanDim = 1;
		    [normal1, normal2] = normal_plane_basis(ortho2);
                } else {
                    self.orthogonalize(ortho1.copy(vec), ortho2.copy(otherVec2));
                    spanDim = 2;
                }
            }
            else if(!linIndep) {
                // otherVec1 is nonzero; otherVec2 is a multiple
                projection.copy(vec).projectOnVector(otherVec1);
                diff.copy(projection).sub(vec);
                if(diff.dot(diff) < snap_threshold) {
                    // Snap to OtherVec1
                    vec.copy(projection);
                    ortho1.copy(otherVec1).normalize();
                    ortho2.set(0, 0, 0);
                    spanDim = 1;
		    [normal1, normal2] = normal_plane_basis(ortho1);

                } else {
                    self.orthogonalize(ortho1.copy(vec), ortho2.copy(otherVec1));
                    spanDim = 2;
                }
            }
            else {
                // otherVec1 and otherVec2 are linearly independent
                // First try snapping to otherVec1
                projection.copy(vec).projectOnVector(otherVec1);
                diff.copy(projection).sub(vec);
                if(diff.dot(diff) < snap_threshold) {
                    vec.copy(projection);
                    self.orthogonalize(
                        ortho1.copy(otherVec1), ortho2.copy(otherVec2));
                    spanDim = 2;
                } else {
                    // Now try snapping to otherVec2
                    projection.copy(vec).projectOnVector(otherVec2);
                    diff.copy(projection).sub(vec);
                    if(diff.dot(diff) < snap_threshold) {
                        vec.copy(projection);
                        self.orthogonalize(
                            ortho1.copy(otherVec1), ortho2.copy(otherVec2));
                        spanDim = 2;
                    } else {

                        // Try snapping to the plane
                        diff.copy(vec).projectOnVector(cross);
                        if(diff.dot(diff) < snap_threshold) {
                            vec.sub(diff);
                            self.orthogonalize(
                                ortho1.copy(otherVec1),
                                ortho2.copy(otherVec2));
                            spanDim = 2;
                        } else
                            spanDim = 3;
                    }
                }
            }

            self.zeroPoints.set('visible', vec1Zero || vec2Zero || vecZero);

	    if (spanDim == 2) {
		normal1 = normal2 = normal_line(ortho1, ortho2);
	    }

            updateSpan(spanDim);
        };
    }).apply(this);

    // Make the vectors draggable
    var draggable = new Draggable({
        view:   this.view,
        points: vectors,
        size:   30,
        hiliteColor: [0, 1, 1, .75],
        onDrag: onDrag,
    });

    if(paramsQS.indep)
        this.label.innerHTML =
            'The vectors ' + katex.renderToString(
                "\\{\\color{#" + tColor1.getHexString() + "}{v_1}," +
                    "\\color{#" + tColor2.getHexString() + "}{v_2}," +
                    "\\color{#" + tColor3.getHexString() + "}{v_3}\\}")
            + ' are <strong><span id="span-type">linearly independent</span></strong>'
            + "<br><br>[Drag the vector heads with the mouse to move them]";
    else
        this.label.innerHTML =
        'The span of ' + katex.renderToString(
            "\\{\\color{#" + tColor1.getHexString() + "}{v_1}," +
                "\\color{#" + tColor2.getHexString() + "}{v_2}," +
                "\\color{#" + tColor3.getHexString() + "}{v_3}\\}")
        + ' is <strong><span id="span-type">space</span></strong>'
	+ '<br>The orthogonal complement is '
	+ '<strong><span id="complement-type">a point</span></strong>'
        + "<br><br>[Drag the vector heads with the mouse to move them]";
    spanType = document.getElementById("span-type");
    complementType = document.getElementById("complement-type");
    spanType.style.backgroundColor = surfaceColor.getStyle();
    complementType.style.backgroundColor = complementColor.getStyle();
    // Initialize span
    onDrag(new THREE.Vector3(vector3[0], vector3[1], vector3[2]));
    mathbox.print();
});