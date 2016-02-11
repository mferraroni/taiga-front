(function() {
    var multipleSortableClass = 'ui-multisortable-multiple';
    var mainClass = 'main-drag-item';

    var isBelow = function(elm, compare) {
        var elmOriginalPosition = elm.data('dragmultiple:originalPosition');
        var compareOriginalPosition = compare.data('dragmultiple:originalPosition');

        return elmOriginalPosition.top > compareOriginalPosition.top;
    };

    var reset = function(elm) {
        $(elm)
            .removeAttr('style')
            .data('dragMultipleActive', false);
    };

    var sort = function(positions) {
        var current = dragMultiple.items.elm;

        positions.after.reverse();

        $.each(positions.after, function () {
            reset(this);
            current.after(this);
        });

        $.each(positions.before, function () {
            reset(this);
            current.before(this);
        });
    };

    var sortPositions = function() {
        var current = dragMultiple.items.elm;
        var container = dragMultiple.items.container;

        //saved if the elements are after or before the current
        var insertAfter = [];
        var insertBefore = [];

        $(container).find('.' + multipleSortableClass).each(function () {
            var elm = $(this);


            if (elm.hasClass(mainClass) || !current.hasClass(multipleSortableClass)) return;

            if (isBelow(elm, current)) {
                insertAfter.push(elm);
            } else {
                insertBefore.push(elm);
            }
        });

        return {'after': insertAfter, 'before': insertBefore};
    };

    var drag = function() {
        var current = dragMultiple.items.elm;
        var container = dragMultiple.items.container;

        if (!dragMultiple.items.shadow) {
            dragMultiple.items.shadow = $('.' + mainClass +':last');

            var shadowData = dragMultiple.items.shadow.data('dragmultiple:originalPosition');

            current.data('dragmultiple:originalPosition', shadowData);
        }

        var shadow = dragMultiple.items.shadow;

        // following the drag element
        var currentLeft = shadow.position().left;
        var currentTop = shadow.position().top;
        var currentZIndex = shadow.css('z-index');
        var currentPosition = shadow.css('position');

        var positions = sortPositions();

        positions.before.reverse();

        [{'positions': positions.after, type: 'after'},
         {'positions': positions.before, type: 'before'}]
            .forEach(function (item) {
                $.each(item.positions, function (index, elm) {
                    var top;

                    if (item.type === 'after') {
                        top =  currentTop + ((index + 1) * current.outerHeight());
                    } else {
                        top =  currentTop - ((index + 1) * current.outerHeight());
                    }

                    elm
                        .css({
                            width: elm.outerWidth(),
                            height: elm.outerHeight(),
                            position: currentPosition,
                            zIndex: currentZIndex,
                            top: top,
                            left: currentLeft
                        });
                });
            });
    };

    var stop = function() {
        var current = dragMultiple.items.elm;
        var container = dragMultiple.items.container;

        $(window).off('mousemove.dragmultiple');

        //save the order of the elements relative to the main
        var positions = sortPositions(container, current);

        sort(positions);

        var draggedItems = dragMultiple.items.draggedItems;

        // reset
        dragMultiple.items = {};
        dragMultiple.activeMultiDrag = false;

        $('.' + mainClass).removeClass(mainClass);

        return draggedItems;
    };

    var dragMultiple = {
        activeMultiDrag: false
    };

    dragMultiple.prepare = function(elm, container) {
        var items = $(container).find('.' + multipleSortableClass);

        if (!$(elm).hasClass(multipleSortableClass) || !(items.length > 1)) {
            return;
        }

        dragMultiple.activeMultiDrag = true;

        dragMultiple.items = {};

        dragMultiple.items.elm = $(elm);
        dragMultiple.items.container = $(container);

        dragMultiple.items.elm.addClass(mainClass);

        dragMultiple.items.draggedItems = items;

        if (dragMultiple.items.elm.hasClass(multipleSortableClass)) {
            dragMultiple.items.container.find('.' + multipleSortableClass).each(function () {
                $(this)
                    .data('dragmultiple:originalPosition', $(this).position())
                    .data('dragMultipleActive', true);
            });
        }
    };

    dragMultiple.start = function() {
        if (dragMultiple.activeMultiDrag) {
            $(window).on('mousemove.dragmultiple', function() {
                drag();
            });
        }
    };

    dragMultiple.stop = function() {
        if (dragMultiple.activeMultiDrag) {
            return stop();
        } else {
            return [];
        }
    };

    window.dragMultiple = dragMultiple;
}());
