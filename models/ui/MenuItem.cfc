component accessors="true"{

	property name="items"			type="array";
	property name="label"				type="string";
	property name="icon"				type="string";
	property name="to"					type="string";

    this.memento = {
        defaultIncludes = [ "*" ]
    };
	
	MenuItem function init(){
		variables.items 	= [];
		variables.label 	= '';
		variables.icon 		= '';
		variables.to 		= '';

		return this;
	}

	MenuItem function additems( MenuItem item ){
        arrayAppend(items,item);

        return this;
    }

	boolean function hasitems( ){
        return ( arrayLen(items) );
    }	

	MenuItem function set( ){
		for (var i in arguments){
			variables[i] = arguments[ i ];
		}
        return this;
    }		
}
