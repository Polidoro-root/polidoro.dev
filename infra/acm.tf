data aws_acm_certificate cert {
	domain      = var.apex_domain
	statuses    = ["ISSUED"]
	most_recent = true
}
