# Copyright (c) 2013 Red Hat
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module Trebuchet
  module Operation
    class ContentPerformance < Trebuchet::Engine::KatelloCommand

      def self.name
        "ContentPerformance"
      end

      def self.description
        "Does a large scale performance test with lots of RHEL repos."
      end


      ENV_LIBRARY = "Library"
      ENV_DEV = "DEV"
      ENV_PROD = "PROD"

      REDHAT_PRODUCT = "Red Hat Enterprise Linux Server"
      REDHAT_REPO = "Red Hat Enterprise Linux 6 Server RPMs x86_64 6Server"

      REDHAT_REPOS = [ "Red Hat Enterprise Linux 6 Server RPMs x86_64 6.1",
                      "Red Hat Enterprise Linux 6 Server RPMs x86_64 6.2",
                       "Red Hat Enterprise Linux 6 Server RPMs x86_64 6.3",
                       "Red Hat Enterprise Linux 6 Server RPMs i386 6.1",
                       "Red Hat Enterprise Linux 6 Server RPMs i386 6.2",
                       "Red Hat Enterprise Linux 6 Server RPMs i386 6.3",
                       "Red Hat Enterprise Linux 6 Server RPMs i386 6Server"]

      PACKAGE = 'telnet-server-0.17-47.el6'
      ERRATA = 'RHBA-2011:0923'


      def katello_commands
        @org = "PerformanceOrg#{rand(10000)}"
        commands  = setup_org

        manifest_path = File.dirname(__FILE__) + '/../../../data/manifest.zip'
        raise "Manifest ./data/manifest.zip not found" if !File.exists?(manifest_path)
        commands += import_manifest(manifest_path)
        commands += enable_repo(REDHAT_PRODUCT, REDHAT_REPO)
        commands += sync(REDHAT_PRODUCT, REDHAT_REPO)
        commands += promote_product(REDHAT_PRODUCT)
        commands += demote_promote_package(REDHAT_PRODUCT, PACKAGE)
        commands += demote_promote_errata(REDHAT_PRODUCT, ERRATA)
        commands += demote_product(REDHAT_PRODUCT)

        REDHAT_REPOS.each do |repo|
          commands += enable_repo(REDHAT_PRODUCT, repo)
          commands += sync(REDHAT_PRODUCT, repo)
        end
        commands += promote_product(REDHAT_PRODUCT)
        commands += demote_product(REDHAT_PRODUCT)
        commands += cleanup
        commands
      end


      def setup_org
        [
          { :id=> :org_create,
            :command => "org create --name=#{esc(@org)}" },
          { :id=>:env_dev_create,
            :command=>"environment create --org=#{esc(@org)} --name=#{esc(ENV_DEV)} --prior=Library"},
          { :id=>:env_prod_create,
            :command=>"environment create --org=#{esc(@org)} --name=#{esc(ENV_PROD)} --prior=#{esc(ENV_DEV)}"}
        ]
      end

      def setup_custom_repo
        [
          { :id=>:provider_create,
            :command=>"provider create --org=#{esc(@org)} --name=#{CUSTOM_PROVIDER}"},
          { :id=>:product_create,
            :command=>"product create --org=#{esc(@org)} --provider=#{CUSTOM_PROVIDER} --name=#{SINGLE_PRODUCT}"},
          { :id=>:repo_create,
            :command=>"repo create --org=#{esc(@org)} --product=#{SINGLE_PRODUCT} --name=#{CUSTOM_REPO} --url=#{REPO_URL}"}
        ]
      end

      def import_manifest(file_path)
        [{ :id=> "upload_manifest",
          :command => "provider import_manifest --org=#{esc(@org)} --name='Red Hat' --file=#{file_path}" }]
      end

      def enable_repo(product, repo)
        [{ :id=> "enable_repo_#{esc(repo)}",
          :command => "repo enable --org=#{esc(@org)} --product=#{esc(product)} --name=#{esc(repo)}" }]
      end

      def sync(product, repo)
        [{ :id=> "sync_repo_#{esc(repo)}",
          :command => "repo synchronize --org=#{esc(@org)} --product=#{esc(product)} --name=#{esc(repo)}" }]
      end

      def promote_product(product)
        @promote_product_count ||= 0
        @promote_product_count += 1
        unique_name = "#{product}_#{@promote_product_count}"
        cs_name = "ChangesetProductPromote_#{unique_name}"
        [
          { :id=>"prod_promote_cs_create_#{unique_name}",
            :command=>"changeset create --org=#{esc(@org)} --name=#{esc(cs_name)} --environment=#{esc(ENV_DEV)} --promotion"},
          { :id=>"prod_promote_cs_add_product_#{unique_name}",
            :command=>"changeset update --org=#{esc(@org)}  --name=#{esc(cs_name)} --environment=#{esc(ENV_DEV)} --add_product=#{esc(product)}"},
          { :id=>"prod_promote_cs_promote_#{unique_name}",
            :command=>"changeset promote --org=#{esc(@org)}  --name=#{esc(cs_name)} --environment=#{esc(ENV_DEV)}"}
        ]
      end

      def demote_product(product)
        @demote_product_count ||= 0
        @demote_product_count += 1
        unique_name = "#{product}_#{@demote_product_count}"
        cs_name = "ChangesetProductDemote_#{unique_name}"
        [
          { :id=>"prod_demote_cs_create_#{unique_name}",
            :command=>"changeset create --org=#{esc(@org)} --name=#{esc(cs_name)} --environment=#{esc(ENV_DEV)} --deletion"},
          { :id=>"prod_demote_add_product_#{unique_name}",
            :command=>"changeset update --org=#{esc(@org)}  --name=#{esc(cs_name)} --environment=#{esc(ENV_DEV)} --add_product=#{esc(product)}"},
          { :id=>"prod_demote_cs_promote_#{unique_name}",
            :command=>"changeset promote --org=#{esc(@org)}  --name=#{esc(cs_name)} --environment=#{esc(ENV_DEV)}"}
        ]
      end

      def demote_promote_package(product, package)
        cs_name1 = "ChangesetPackageDemote"
        cs_name2 = "ChangesetPackagePromote"
        [
          { :id=>:pkg_demote_cs_create,
            :command=>"changeset create --org=#{esc(@org)} --name=#{esc(cs_name1)} --environment=#{esc(ENV_DEV)} --deletion"},
          { :id=>:pkg_demote_add_pkg,
            :command=>"changeset update --org=#{esc(@org)}  --name=#{esc(cs_name1)} --environment=#{esc(ENV_DEV)} " +
                "--from_product=#{esc(product)} --add_package=#{esc(PACKAGE)}"},
          { :id=>:pkg_demote_publish,
            :command=>"changeset promote --org=#{esc(@org)}  --name=#{esc(cs_name1)} --environment=#{esc(ENV_DEV)}"},
          { :id=>:pkg_promote_cs_create,
            :command=>"changeset create --org=#{esc(@org)} --name=#{esc(cs_name2)} --environment=#{esc(ENV_DEV)} --promotion"},
          { :id=>:pkg_promote_add_pkg,
            :command=>"changeset update --org=#{esc(@org)}  --name=#{esc(cs_name2)} --environment=#{esc(ENV_DEV)} " +
                "--from_product=#{esc(product)} --add_package=#{esc(PACKAGE)}"},
          { :id=>:pkg_promote_publish,
            :command=>"changeset promote --org=#{esc(@org)}  --name=#{esc(cs_name2)} --environment=#{esc(ENV_DEV)}"}
        ]
      end

      def demote_promote_errata(product, errata)
        cs_name1 = "ChangesetErrataDemote"
        cs_name2 = "ChangesetErrataPromote"
        [
          { :id=>:errata_demote_cs_create,
            :command=>"changeset create --org=#{esc(@org)} --name=#{esc(cs_name1)} --environment=#{esc(ENV_DEV)} --deletion"},
          { :id=>:errata_demote_add_pkg,
            :command=>"changeset update --org=#{esc(@org)}  --name=#{esc(cs_name1)} --environment=#{esc(ENV_DEV)} " +
                "--from_product=#{esc(product)} --add_erratum=#{esc(errata)}"},
          { :id=>:errata_demote_publish,
            :command=>"changeset promote --org=#{esc(@org)}  --name=#{esc(cs_name1)} --environment=#{esc(ENV_DEV)}"},
          { :id=>:errata_promote_cs_create,
            :command=>"changeset create --org=#{esc(@org)} --name=#{esc(cs_name2)} --environment=#{esc(ENV_DEV)} --promotion"},
          { :id=>:errata_promote_add_pkg,
            :command=>"changeset update --org=#{esc(@org)}  --name=#{esc(cs_name2)} --environment=#{esc(ENV_DEV)} " +
                "--from_product=#{esc(product)} --add_erratum=#{esc(errata)}"},
          { :id=>:errata_promote_publish,
            :command=>"changeset promote --org=#{esc(@org)}  --name=#{esc(cs_name2)} --environment=#{esc(ENV_DEV)}"}
        ]
      end

      def cleanup
          [{ :id=> :org_destroy,
            :command => "org delete --name=#{esc(@org)}" }]
      end

      def esc(string)
        "\"#{string}\""
      end

    end
  end
end
