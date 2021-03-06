class MapController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
    # map
    ra_deg_1 = ((params[:ra_h_1].to_i + params[:ra_m_1].to_i / 60.0) * 15).round(2)
    ra_deg_2 = ((params[:ra_h_2].to_i + params[:ra_m_2].to_i / 60.0) * 15).round(2)
    ra_deg_1_2 = ""
    ra_deg_2_2 = ""
    if(ra_deg_2 < ra_deg_1)
      ra_deg_1 = ra_deg_1.to_s
      ra_deg_2_2 = ra_deg_2.to_s
      ra_deg_2 = '360'
      ra_deg_1_2 = '0'
    else
      ra_deg_1 = ra_deg_1.to_s
      ra_deg_2 = ra_deg_2.to_s
    end
      
    ra_grid = params[:ra_gird].to_i.to_s
    dec_deg_1 = params[:dec_deg_1].to_i
    dec_deg_2 = params[:dec_deg_2].to_i
    if(dec_deg_1 > dec_deg_2)
      dec_deg_2, dec_deg_1 = dec_deg_1, dec_deg_2
    end
    dec_deg_1 = dec_deg_1.to_s
    dec_deg_2 = dec_deg_2.to_s
    dec_grid = params[:dec_gird].to_i.to_s
    @params = params.to_json.to_s
    
    radec_query = "((ra_deg >= " + ra_deg_1 + " and ra_deg <= " + ra_deg_2 + ")"
    if(ra_deg_1_2 != '')
      radec_query += " or (ra_deg >= " + ra_deg_1_2 + " and ra_deg <= " + ra_deg_2_2 + ")"
    end
    radec_query += ") and dec_deg >= " + dec_deg_1 + " and dec_deg <= " + dec_deg_2 
    @radec = radec_query

    # stars
    max_mag = params[:max_mag].to_f.round(2).to_s
    
    # dsos
    gx = params.include?(:gx)
    gx_mag = params[:gx_mag].to_f.round(2).to_s
    gx_size = params[:gx_size].to_i.to_s
    oc = params.include?(:oc)
    oc_mag = params[:oc_mag].to_f.round(2).to_s
    oc_size = params[:oc_size].to_i.to_s
    gc = params.include?(:gc)
    gc_mag = params[:gc_mag].to_f.round(2).to_s
    bn = params.include?(:bn)
    bn_size = params[:bn_size].to_i.to_s
    dn = params.include?(:dn)
    dn_size = params[:dn_size].to_i.to_s
    pn = params.include?(:pn)
    pn_mag = params[:pn_mag].to_f.round(2).to_s
    
    hip_stars = HipStar.where(radec_query + " and mag <= " + max_mag).order("mag")
    tyc_stars = TycStar.where(radec_query + " and mag <= " + max_mag).order("mag")
    ucac_stars = UcacStar.where(radec_query + " and mag <= " + max_mag).order("mag")

    dso_query = ""
    excl = []
    excl << 1 if not gx
    excl << 5 if not oc
    excl << 6 if not gc
    excl << 2 if not bn
    excl << 3 if not dn
    excl << 4 if not pn

    ngcic_dsos = []
    other_dsos = []
    if excl.length < 5
      dso_query += "obj_type_id not in (" + excl.join(",") + ") and " if excl.length > 0
      dso_query += radec_query + " and ("
      querys = []
      querys << "(obj_type_id=1 and mag <= " + gx_mag + " and size_maj <= " + gx_size + ")" if gx
      querys << "(obj_type_id=5 and mag <= " + oc_mag + " and size_maj <= " + oc_size + ")" if oc
      querys << "(obj_type_id=6 and mag <= " + gc_mag + ")" if gc
      querys << "(obj_type_id=2 and size_maj <= " + bn_size + ")" if bn
      querys << "(obj_type_id=3 and size_maj <= " + dn_size + ")" if dn
      querys << "(obj_type_id=4 and mag <= " + pn_mag + ")" if pn
      dso_query += querys.join(" or ") + ")"

      ngcic_dsos = NgcicDso.where(dso_query).order("size_maj desc")
      other_dsos = OtherDso.where(dso_query).order("size_maj desc")
    end
    
    json = "{\n"
    json += "\"hip_stars\": [" + hip_stars.map{|res| res.to_json}.join(", ") + "],\n"
    json += "\"tyc_stars\": [" + tyc_stars.map{|res| res.to_json}.join(", ") + "],\n"
    json += "\"ucac_stars\": [" + ucac_stars.map{|res| res.to_json}.join(", ") + "],\n"
    json += "\"ngcic_dsos\": [" + ngcic_dsos.map{|res| res.to_json}.join(", ") + "],\n"
    json += "\"other_dsos\": [" + other_dsos.map{|res| res.to_json}.join(", ") + "]\n"
    json += "}"
    @data = json
  end
end
