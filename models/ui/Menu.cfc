component accessors="true"{
	property name="wirebox"			inject="wirebox";
    property name="items"			type="array";


    this.memento = {
        defaultIncludes = [ "*" ]
    };


	Menu function init(){
		variables.items = [];

		return this;
	}

	Menu function addItem( MenuItem item ){
        arrayAppend(items,item);

        return this;
    }

	Menu function addMenuItem( ){
        var i =  wirebox.getInstance('menuitem@cbadmin');
        i.set( argumentcollection = arguments );
        addItem(i);

        return this;
    }       
    
}
