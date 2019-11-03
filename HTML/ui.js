function CloseInventory() {
    $(".container-item-tudo").html('');
    $(".container-proximo").html('');
	$("#inventario").fadeOut();
    $.post('http://vrp_inventario/fechar', JSON.stringify({}));
}

$(document).keyup(function(e) {
     if (e.key === "Escape") {
        CloseInventory()
    }
});

$(document).ready(function(){

    $(".container-item-tudo").on('click', '#usar', function () {
        $("#inventario").fadeOut();
        $.post('http://vrp_inventario/usar', JSON.stringify({id: $(this).data('id')}));
        $.post('http://vrp_inventario/fechar', JSON.stringify({}));
        $(".container-item-tudo").html('');
    });

    $(".container-item-tudo").on('click', '#dropar', function () {
        $("#inventario").fadeOut();
        $.post('http://vrp_inventario/dropar', JSON.stringify({id: $(this).data('id')}));
        $.post('http://vrp_inventario/fechar', JSON.stringify({}));
        $(".container-item-tudo").html('');
    });

    window.addEventListener('message', function(event) {
        let data = event.data;

        if (data.show) {
            let item_inventory = data.inventario;
            
            $("#inventario").fadeIn();
            $("#inventario").show();

            for (let item in item_inventory) {
                let items = []
                items.push(item)
                let res = items.map(s => s.indexOf('wbody|') === 0 ? s.substr(6) : s)
                
                $(".container-item-tudo").append(`
                <div class="focus" onclick="selectItem(this)" data-name="${item_inventory[item].name}"  data-amount="${item_inventory[item].amount}" data-idname="${item}" >
                    <div id="item" class="item">
                        <p id="quantidade">${item_inventory[item].amount}x</p>
                        <img id="item-img" src="images/${res}.png">
                        <div class="nome-fundo-inv">
                            <p id="nome">${item_inventory[item].name}</p>
                        </div>
                    </div>  
                    <div class="actions" style="display:none">
                        <button id="usar" data-id="${item}">Usar</button>
                        <button id="dropar" data-id="${item}">Dropar</button>
                    </div>
                </div>
                `);

                function onDOMReady(f) {
                    /in/.test(document.readyState) ? setTimeout(arguments.callee.name + '(' + f + ')', 9) : f()
                }

                function fadeElement(a, b) {
                    if (b !== 'show') {
                        return a.style.opacity = setTimeout(function() {
                            a.style.display = 'none'
                        }, 200) * 0
                    }
                    a.style.display = 'block';
                    setTimeout(function() {
                        a.style.opacity = 1
                    }, 30)
                }
            
                function addListener(a, b, c) {
                    ((typeof a == "string") ? document.querySelector(a) : a).addEventListener(b, c)
                }
            
                onDOMReady(function() {
                    Array.from(document.querySelectorAll(".jctx-host")).forEach((z, i) => {
                        addListener(z, "contextmenu", function(event) {
                            Array.from(document.querySelectorAll(".jctx")).forEach((k, i) => {
                                k.style.display = 'none'
                            });
                            event.preventDefault();
                            let mID = '';
                            Array.from(z.classList).forEach((y, i) => {
                                if (~y.indexOf("jctx-id-")) {
                                    mID = '.' + y
                                }
                            });
                            x = document.querySelector(".jctx" + mID);
                            let maxLeft = (window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth) - 10 - x.getBoundingClientRect().width;
                            let maxTop = (window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight) - 10 - x.getBoundingClientRect().height;
                            fadeElement(x, 'show');
                            x.style.left = (event.pageX > maxLeft ? maxLeft : event.pageX) + "px",
                            x.style.top = (event.pageY > maxTop ? maxTop : event.pageY) + "px"
                        })
                    });
                });
            }
        }  

        if (data.showSecundary) {
            let inventory_secundary = data.InventarioSecundario;
            
            $("#inventario").fadeIn();
            $("#inventario").show();

            for (let item in inventory_secundary) {
                let items = []
                items.push(item)
                let res = items.map(s => s.indexOf('wbody|') === 0 ? s.substr(6) : s)
                
                $(".inventario-proximo").append(`
                <div class="focus" onclick="selectItem(this)" data-name="${inventory_secundary[item].name}"  data-amount="${inventory_secundary[item].amount}" data-idname="${item}" >
                    <div id="item" class="item">
                        <p id="quantidade">${inventory_secundary[item].amount}x</p>
                        <img id="item-img" src="images/${res}.png">
                        <div class="nome-fundo-inv">
                            <p id="nome">${inventory_secundary[item].name}</p>
                        </div>
                    </div>  
                    <div class="actions" style="display:none">
                        <button id="usar" data-id="${item}">Usar</button>
                        <button id="dropar" data-id="${item}">Dropar</button>
                    </div>
                </div>
                `);
            }
        }

    });
});

function selectItem(element) {
    $(".focus").css("background-color", "background-color: rgba(0, 0, 0, 0.28);");
    $(".actions").css("display", "none");
    $(element).css("background-color", "rgba(0, 0, 0, 0.828)");
    $(element).css("margin-right", "80px");
    $(element).children().last().css("display", "block");
}