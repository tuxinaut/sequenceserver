FROM debian:buster-slim

LABEL Description="Intuitive local web frontend for the BLAST bioinformatics tool"
LABEL MailingList="https://groups.google.com/forum/#!forum/sequenceserver"
LABEL Website="http://www.sequenceserver.com"

RUN apt-get update && apt-get install -y --no-install-recommends \
        ruby ruby-dev build-essential curl gnupg git wget \
        zlib1g-dev && rm -rf /var/lib/apt/lists/*

VOLUME ["/db"]
EXPOSE 4567

COPY . /sequenceserver
WORKDIR /sequenceserver
# Install bundler, then use bundler to install SequenceServer's dependencies,
# and then use SequenceServer to install BLAST. In the last step, -s is used
# so that SequenceServer will exit after writing configuration file instead
# of starting up, while -d is used to suppress questions about database dir.
RUN gem install bundler && \
        bundle install --without=development && \
        yes '' | bundle exec bin/sequenceserver -s -d spec/database/sample && \
        touch ~/.sequenceserver/asked_to_join && \
        rm /root/.sequenceserver/ncbi-blast-2.10.0+-x64-linux.tar.gz && \
        cd '/root/.sequenceserver/ncbi-blast-2.10.0+/bin/' && \
        rm \
            deltablast \
            legacy_blast.pl \
            makeprofiledb \
            rpstblastn \
            blastdb_aliastool \
            cleanup-blastdb-volumes.py \
            dustmasker \
            psiblast \
            segmasker \
            update_blastdb.pl \
            blastdbcheck \
            convert2blastmask \
            get_species_taxids.sh \
            makembindex \
            rpsblast \
            windowmasker

CMD ["bundle", "exec", "bin/sequenceserver", "-d", "/db"]
