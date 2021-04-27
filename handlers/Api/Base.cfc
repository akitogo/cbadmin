component extends="cborm.models.resources.BaseHandler"
{
    function index( event, rc, prc ){
        param rc.qs                 = '';
        param rc.page               = 1;
        param rc.isActive           = true;

        param rc.c          = "";
        
        if ( isJson (rc.qs) ){
            rc.qs = DeserializeJSON( rc.qs );
        }

        if( isSimpleValue(rc.qs) and rc.qs == '' ){
            super.index( argumentCollection=arguments );
            return;
        }

        //writedump(rc.qs); abort;
        rc.maxrows                  = rc.qs.rows;
        if (rc.qs.first)
            rc.page                 = rc.qs.first / rc.qs.rows + 1;


        if (structKeyExists(rc.qs,'sortField') && !isNull(rc.qs.sortField)){
            rc.sortOrder            = rc.qs.sortField;
        }
        if (structKeyExists(rc.qs,'sortOrder') && !isNull(rc.qs.sortOrder)){
            switch(rc.qs.sortOrder){
                case '-1':
                    rc.sortOrder            &= ' asc';
                break;
                case '1':
                    rc.sortOrder            &= ' desc';
                break;

            }
        }
        if(structKeyExists(variables, 'filter')) {
            arguments.criteria = newCriteria();

            for (var singleFilter in variables.filter){
                arguments.criteria.when( structKeyExists( rc.qs.filters, singleFilter ) && !isNull( rc.qs.filters[singleFilter].value ), (c) => {
                    c.like( singleFilter, '%' & rc.qs.filters[singleFilter].value & '%' );
                } );      
            }

        }


        super.index( argumentCollection=arguments );
    }    
}